# This recipe installs the neon video_server process

include_recipe "neon::default"

# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Create a video_server user
user "videoserver" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "video_server::config"

# Install the python dependencies

# Make directories 
directory node[:video_server][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end
file node[:video_server][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end

node[:deploy].each do |app_name, deploy|
  if app_name != "video_server" then
    next
  end

  repo_path = get_repo_path(app_name)
  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")

  # Install the neon code
  include_recipe "neon::full_py_repo"


  # Test video_server
  app_tested = "#{repo_path}/TEST_DONE"
  file app_tested do
    user "neon"
    group "neon"
    action :nothing
    subscribes :delete, "bash[compile_video_server]", :immediately
  end
  bash "test_video_server" do
    action :nothing
    cwd repo_path
    user "neon"
    group "neon"
    code <<-EOH
       . enable_env
       nosetests --exe api utils supportServices
    EOH
    not_if {  ::File.exists?(app_tested) }
    notifies :restart, "service[video_server]", :delayed
    notifies :create, "file[#{app_tested}]"
  end

  # Write the daemon service wrapper
  template "/etc/init/video_server.conf" do
    source "video_server_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:video_server][:config],
                :user => "neon",
                :group => "neon",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/video_server-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "video_server",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:video_server][:log_file]
              })
  end

  service "video_server" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
  end

  # create video request script
  template '/etc/init.d/create_video_requests' do
    source 'create_requests.erb'
    mode '0755'
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:video_server][:config]
             )}
  end

  #CRON to create video requests
  cron "createvideorequests" do
    action :create
    user "videoserver"
    minute "*/5"
    command "/etc/init.d/create_video_requests"
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off video_server
  service "video_server" do
    action :stop
  end
end
