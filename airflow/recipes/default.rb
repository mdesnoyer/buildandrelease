
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

# Install the python dependencies
python_pip airflow do
  version "1.3.0"
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








pydeps = {
  "numpy" => "1.6.1",
  "futures" => "2.1.5",
  "tornado" => "4.1",
  "setuptools" => "4.0.1",
  "avro" => "1.7.6",
  "boto" => "2.32.1",
  "impyla" => "0.8.1",
  "simplejson" => "2.3.2",
  "paramiko" => "1.14.0",
  "nose" => "1.3.0",
  "thrift" => "0.9.1",
  "PyYAML" => "3.10",
  "dateutils" => "0.6.6",
  "winpdb" => "1.4.8",
  "pyhs2" => "0.6.0",
  "happybase" => "0.9"
}

# Install the python dependencies
pydeps.each do |package, vers|
  python_pip package do
    version vers
    options "--no-index --find-links https://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
  end
end



if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off the statsmanager
  service "neon-statsmanager" do
    action :stop
  end

  file "/etc/init/neon-statsmanager.conf" do
    action :delete
  end
end


#              :mr_jar => "#{repo_path}/stats/java/target/neon-stats-1.0-job.jar"
