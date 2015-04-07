# This recipe installs the neon monitoring process

include_recipe "neon::default"

# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Create a monitoring user
user "monitoring" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "monitoring::config"

# Install the python dependencies

# Make directories 
directory node[:monitoring][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end

file node[:monitoring][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end

node[:deploy].each do |app_name, deploy|
  if app_name != "monitoring" then
    next
  end

  repo_path = get_repo_path(app_name)
  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")
  
  # Install the neon code
  include_recipe "neon::full_py_repo"

  # Write the daemon service wrapper
  template "/etc/init/benchmark_videopipeline.conf" do
    source "monitoring_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:monitoring][:config],
                :user => "neon",
                :group => "neon",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/monitoring-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "benchmark_videopipeline",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:monitoring][:log_file]
              })
  end

  service "benchmark_videopipeline" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{repo_path}]", :delayed
  end
end

if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off monitoring
  service "monitoring" do
    action :stop
  end
end
