# Installs Airflow for cleaning and loading click logs via stats modules

user node[:airflow][:user] do
  action :create
  shell "/bin/false"
  home node[:airflow][:home]
end

directory node[:airflow][:airflow_logs] do
  user node[:airflow][:user]
  group node[:airflow][:group]
  mode "2775"
  recursive true
end

directory node[:airflow][:home] do
  user node[:airflow][:user]
  group node[:airflow][:group]
  mode "2775"
  recursive true
end

include_recipe "apt::default"
include_recipe "airflow::config"

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

# Install Airflow and used submodules
py_deps = [
  'airflow',
  'airflow[mysql]',
  'airflow[s3]',
  'airflow[celery]'
]
py_deps.each do |dep|
  python_pip dep do
    version node[:airflow][:version]
  end
end

# ----------------------------------------
# Initialize the airflow metadata database
# ----------------------------------------
execute "airflow initialize db" do
  command "sudo su -c 'airflow initdb' -s /bin/sh statsmanager"
end

# ----------------------------
# Airflow services
# ----------------------------

service "airflow-web" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
  action [:enable, :start]
  subscribes :restart, "template[/etc/init/airflow-web.conf]", :delayed
  subscribes :restart, "template[#{node[:airflow][:config_file]}]", :delayed
end

service "airflow-scheduler" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
  action [:enable, :start]
  subscribes :restart, "template[/etc/init/airflow-scheduler.conf]", :delayed
  subscribes :restart, "template[#{node[:airflow][:config_file]}]", :delayed
end

service "airflow-worker" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
  action [:enable, :start]
  subscribes :restart, "template[/etc/init/airflow-worker.conf]", :delayed
  subscribes :restart, "template[#{node[:airflow][:config_file]}]", :delayed
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
