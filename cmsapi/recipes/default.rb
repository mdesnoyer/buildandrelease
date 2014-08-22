# This recipe installs the neon cmsapi process

include_recipe "neon::default"

# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Create a cmsapi user
user "cmsapi" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "cmsapi::config"

# Install the python dependencies

# Make directories 
directory node[:cmsapi][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end
file node[:cmsapi][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end

node[:deploy].each do |app_name, deploy|
  if app_name != "cmsapi" then
    next
  end

  repo_path = get_repo_path("api")
  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")

  # Install the neon code
  include_recipe "neon::full_py_repo"


  # Test cmsapi
  app_tested = "#{repo_path}/TEST_DONE"
  file app_tested do
    user "neon"
    group "neon"
    action :nothing
    subscribes :delete, "bash[compile_cmsapi]", :immediately
  end
  bash "test_cmsapi" do
    action :nothing
    cwd repo_path
    user "neon"
    group "neon"
    code <<-EOH
       . enable_env
       nosetests --exe api utils supportServices
    EOH
    not_if {  ::File.exists?(app_tested) }
    notifies :restart, "service[cmsapi]", :delayed
    notifies :create, "file[#{app_tested}]"
  end

  # Write the daemon service wrapper
  template "/etc/init/cmsapi.conf" do
    source "cmsapi_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:cmsapi][:config],
                :user => "neon",
                :group => "neon",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/cmsapi-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "cmsapi",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:cmsapi][:log_file]
              })
  end

  service "cmsapi" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off cmsapi
  service "cmsapi" do
    action :stop
  end
end
