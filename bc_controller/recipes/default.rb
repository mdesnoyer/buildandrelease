# This recipe installs the neon bc_controller process

include_recipe "neon::default"

# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Create a bc_controller user
user "bc_controller" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "bc_controller::config"

# Make directories 
directory node[:bc_controller][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end
file node[:bc_controller][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end

node[:deploy].each do |app_name, deploy|
  Chef::Log.info("Start Deploying app #{app_name}") 

  if app_name != "brightcove_controller" then
    next
  end

  repo_path = get_repo_path(app_name)
  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")

  # Install the neon code
  include_recipe "neon::full_py_repo"

  # Test bc_controller
  app_tested = "#{repo_path}/TEST_DONE"
  file app_tested do
    user "neon"
    group "neon"
    action :nothing
    subscribes :delete, "bash[compile_bc_controller]", :immediately
  end
  bash "test_bc_controller" do
    cwd repo_path
    user "neon"
    group "neon"
    code <<-EOH
       . enable_env
       nosetests --exe api utils controllers cmsdb
    EOH
    not_if {  ::File.exists?(app_tested) }
    notifies :restart, "service[bc_controller]", :delayed
    notifies :create, "file[#{app_tested}]"
  end

  # Write the daemon service wrapper
  template "/etc/init/bc_controller.conf" do
    source "bc_controller_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:bc_controller][:config],
                :user => "neon",
                :group => "neon",
              })
  end
  template "/etc/init/bc_ingester.conf" do
    source "bc_ingester_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:bc_controller][:ingester_config],
                :user => "neon",
                :group => "neon",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/bc_controller-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "bc_controller",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:bc_controller][:log_file]
              })
  end
  template "/etc/init/bc_ingester-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "bc_ingester",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:bc_controller][:ingester_log_file]
              })
  end

  # TODO: Re-enable the controller when we actually run tests through
  # Brightcove
  #service "bc_controller" do
  #  provider Chef::Provider::Service::Upstart
  #  supports :status => true, :restart => true, :start => true, :stop => true
  #  action [:enable, :start]
  #  subscribes :restart, "git[#{repo_path}]", :delayed
  #end
  service "bc_ingester" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{repo_path}]", :delayed
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off bc_controller
  service "bc_controller" do
    action :stop
  end
end
