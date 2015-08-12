
# Create an airflow user
user node[:airflow][:user] do
  group node[:airflow][:group]
  action :create
  system true
  shell "/bin/false"
end

directory node[:airflow][:log_dir] do
  user node[:airflow][:user]
  group node[:airflow][:user]
  mode "2775"
  recursive true
end

# Build dependencies
deps = [
  'libmysqlclient-dev',
  'libblas-dev',
  'liblapack-dev',
  'libkrb5-dev',
  'libsasl2-dev'
]

deps.each do |dep|
  package dep do
    :install
  end
end

# Install the python dependencies
py_deps = [
  'airflow',
  'airflow[mysql]',
  'airflow[s3]',
  'airflow[hive]'
]
py_deps.each do |dep|
  python_pip dep do
    version "1.3.0"
  end
end

# Airflow Webserver service
template "/etc/init/airflow-web.conf" do
  source "airflow-web.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :user => node[:airflow][:user],
              :group => node[:airflow][:group],
              :airflow_home => node[:airflow][:airflow_home],
              :webserver_port => node[:airflow][:webserver_port]
            })
end

# Airflow Scheduler service
template "/etc/init/airflow-scheduler.conf" do
  source "airflow-scheduler.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :user => node[:airflow][:user],
              :group => node[:airflow][:group],
              :airflow_home => node[:airflow][:airflow_home]
            })
end

# Airflow Worker (Celery-based)
template "/etc/init/airflow-worker.conf" do
  source "airflow-worker.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :user => node[:airflow][:user],
              :group => node[:airflow][:group],
              :airflow_home => node[:airflow][:airflow_home]
            })
end

# Airflow configuration
template "#{node[:airflow][:airflow_home]}/airflow.cfg" do
  source "airflow.cfg.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :airflow_home => node[:airflow][:airflow_home]
              :airflow_logs => node[:airflow][:airflow_logs]
              :db_user => node[:airflow][:db_user]
              :db_password => node[:airflow][:db_password]
              :db_host => node[:airflow][:db_host]
              :db_port => node[:airflow][:db_port]
              :db_name => node[:airflow][:db_name]
            })
end

service "airflow-worker" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{repo_path}]", :delayed
end


# template the cluster.conf
#              :mr_jar => "#{repo_path}/stats/java/target/neon-stats-1.0-job.jar"
