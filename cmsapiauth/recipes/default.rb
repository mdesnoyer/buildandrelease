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

include_recipe "cmsapiauth::config"

# Install the python dependencies

# Make directories 
directory node[:cmsapiauth][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end
file node[:cmsapiauth][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end
 
node[:deploy].each do |app_name, deploy|
  if app_name == "cmsapi_auth" then
    Chef::Log.info("Deploying app base installs.")
    include_recipe "neon::full_py_repo"
    include_recipe "neon-nginx::default"

    template "/etc/init/nginx-email.conf" do
      source "mail-on-restart.conf.erb"
      cookbook "neon"
      owner "root"
      group "root"
      mode "0644"
      variables({
                  :service => "nginx",
                  :host => node[:hostname],
                  :email => node[:neon][:ops_email],
                  :log_file => "#{node[:nginx][:log_dir]}/error.log"
                })
    end

    service "nginx" do
      action [:enable, :start]
    end
    
    repo_path = get_repo_path(app_name)
    Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")
    
    app_tested = "#{repo_path}/TEST_DONE"

    file app_tested do
      user "neon"
      group "neon"
      action :nothing
      subscribes :delete, "bash[compile_cmsapiauth]", :immediately
    end
    bash "test_cmsapiauth" do
      cwd repo_path
      user "neon"
      group "neon"
      code <<-EOH
         . enable_env
         nosetests --exe cmsapiv2 cmsdb utils
      EOH
      not_if {  ::File.exists?(app_tested) }
      notifies :restart, "service[cmsapiauth]", :delayed
      notifies :create, "file[#{app_tested}]"
    end

    template "/etc/init/cmsapiauth.conf" do
      source "cmsapiauth_service.conf.erb"
      owner "root"
      group "root"
      mode "0644"
      variables({
                  :neon_root_dir => "#{repo_path}",
                  :config_file => node[:cmsapiauth][:config],
                  :user => "neon",
                  :group => "neon",
                })
    end
    # Write a script that will send a mail when the service dies
    template "/etc/init/cmsapiauth-email.conf" do
      source "mail-on-restart.conf.erb"
      cookbook "neon"
      owner "root"
      group "root"
      mode "0644"
      variables({
                  :service => "cmsapiauth",
                  :host => node[:hostname],
                  :email => node[:neon][:ops_email],
                  :log_file => node[:cmsapiauth][:log_file]
                })
    end
    service "cmsapiauth" do
      provider Chef::Provider::Service::Upstart
      supports :status => true, :restart => true, :start => true, :stop => true
      action [:enable, :start]
      subscribes :restart, "git[#{repo_path}]", :delayed
    end
  end 
end

if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off cmsapi
  service "cmsapiauth" do
    action :stop
  end
end
