# This recipe installs the neon mastermind process

include_recipe "neon::default"

# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Create a mastermind user
user "mastermind" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "mastermind::config"

# Install the python dependencies

# Make directories 
directory node[:mastermind][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end
file node[:mastermind][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end

node[:deploy].each do |app_name, deploy|
  if app_name != "mastermind" then
    next
  end

  repo_path = get_repo_path("mastermind")
  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")

  # Install the neon code
  include_recipe "neon::full_py_repo"


  # Test mastermind
  app_tested = "#{repo_path}/TEST_DONE"
  file app_tested do
    user "neon"
    group "neon"
    action :nothing
    subscribes :delete, "bash[compile_mastermind]", :immediately
  end
  bash "test_mastermind" do
    cwd repo_path
    user "neon"
    group "neon"
    code <<-EOH
       . enable_env
       nosetests --exe mastermind cmsdb utils
    EOH
    not_if {  ::File.exists?(app_tested) }
    notifies :restart, "service[mastermind]", :delayed
    notifies :create, "file[#{app_tested}]"
  end

  # Write the daemon service wrapper
  template "/etc/init/mastermind.conf" do
    source "mastermind_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:mastermind][:config],
                :user => "neon",
                :group => "neon",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/mastermind-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "mastermind",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:mastermind][:log_file]
              })
  end

  service "mastermind" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off mastermind
  service "mastermind" do
    action :stop
  end
end
