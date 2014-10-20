# This recipe installs the neon video_client process

include_recipe "neon::default"

# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Create a video_client user
user "video_client" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "video_client::config"

# Install the python dependencies

# Make directories 
directory node[:video_client][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end
file node[:video_client][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end

node[:deploy].each do |app_name, deploy|
  if app_name != "video_client" then
    next
  end

  repo_path = get_repo_path("video_client")

  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")
  
  # Configure model data
  include_recipe "video_client::modeldata"

  # Install the neon code
  include_recipe "neon::full_py_repo"

  # Test video_client
  app_tested = "#{repo_path}/TEST_DONE"
  file app_tested do
    user "neon"
    group "neon"
    action :nothing
    subscribes :delete, "bash[compile_video_client]", :immediately
  end
  bash "test_video_client" do
    cwd repo_path
    user "neon"
    group "neon"
    code <<-EOH
       . enable_env
       nosetests --exe api utils supportServices model
       model/bin/TextDetectionTest
    EOH
    not_if {  ::File.exists?(app_tested) }
    notifies :restart, "service[video_client]", :delayed
    notifies :create, "file[#{app_tested}]"
  end

  # Write the daemon service wrapper
  template "/etc/init/video_client.conf" do
    source "video_client_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:video_client][:config],
                :user => "neon",
                :group => "neon",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/video_client-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "video_client",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:video_client][:log_file]
              })
  end

  service "video_client" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{repo_path}]", :delayed
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off video_client
  service "video_client" do
    action :stop
  end
end
