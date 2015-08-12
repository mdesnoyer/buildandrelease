
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
              :airflow_home => node[:airflow][:airflow_home],
              :airflow_logs => node[:airflow][:airflow_logs],
              :db_user => node[:airflow][:db_user],
              :db_password => node[:airflow][:db_password],
              :db_host => node[:airflow][:db_host],
              :db_port => node[:airflow][:db_port],
              :db_name => node[:airflow][:db_name]
            })
end


# capture logs via flume
# https://flume.apache.org/FlumeUserGuide.html#spooling-directory-source
# default[:neon_logs][:flume_streams][:stream_name] = {
#   :sources => [source_names],
#   :channels => [channel_names],
#   :sinks => [sink_names],
#   :sinkgroups => [sinkgroup_names],
#   :template => template_file,
#   :template_cookbook => cookbook containing the template_file
#                         [defaults to neon_logs]
#   :variables => {hash of variables for the template}

# Configure the flume agent that will listen to the logs from the
# stats manager job
# node.default[:neon_logs][:flume_streams][:airflow_logs] =
#   get_jsonagent_config(node[:neon_logs][:json_http_source_port],
#                        "airflow")

# if node[:opsworks][:activity] == "config" then
#   include_recipe "neon_logs::flume_core_config"
# else
#   include_recipe "neon_logs::flume_core"
# end

service "airflow-webserver" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "template[/etc/init/airflow-web.conf]", :delayed
end

service "airflow-scheduler" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "template[/etc/init/airflow-scheduler.conf]", :delayed
end

service "airflow-worker" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "template[/etc/init/airflow-worker.conf]", :delayed
end


if ['shutdown'].include? node[:opsworks][:activity] then
  services = [
    'airflow-worker',
    'airflow-scheduler',
    'airflow-web'
  ]
  services.each do |service_name|
    service service_name do
      action :stop
    end
  end
end

# template the cluster.conf
#              :mr_jar => "#{repo_path}/stats/java/target/neon-stats-1.0-job.jar"
