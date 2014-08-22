# This recipe installs the neon controller process

include_recipe "neon::default"

# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Create a controller user
user "controller" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "controller::config"

# Install the python dependencies

# Make directories 
directory node[:controller][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end
file node[:controller][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end

node[:deploy].each do |app_name, deploy|
  if app_name != "controller" then
    next
  end

  repo_path = get_repo_path("controllers")
  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")

  # Install the neon code
  include_recipe "neon::full_py_repo"


  # Test controller
  app_tested = "#{repo_path}/TEST_DONE"
  file app_tested do
    user "neon"
    group "neon"
    action :nothing
    subscribes :delete, "bash[compile_controller]", :immediately
  end
  bash "test_controller" do
    action :nothing
    cwd repo_path
    user "neon"
    group "neon"
    code <<-EOH
       . enable_env
       nosetests --exe api utils supportServices
    EOH
    not_if {  ::File.exists?(app_tested) }
    notifies :restart, "service[controller]", :delayed
    notifies :create, "file[#{app_tested}]"
  end

  # Write the daemon service wrapper
  template "/etc/init/controller.conf" do
    source "controller_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:controller][:config],
                :user => "neon",
                :group => "neon",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/controller-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "controller",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:controller][:log_file]
              })
  end

  service "controller" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off controller
  service "controller" do
    action :stop
  end
end
