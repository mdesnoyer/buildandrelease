# Imageserving platform 

include_recipe "neon::default"

  
# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Make directories 
file node[:neonisp][:log_file] do
  user "#{node[:nginx][:user]}"
  group "neon"
  mode "0644"
end
  
file node[:neonisp][:mastermind_download_location] do
  user "#{node[:nginx][:user]}"
  group "neon"
  mode "0644"
end

include_recipe "neonisp::config"

if node[:opsworks][:activity] == 'deploy' then
  # Install the neon code (Make sure to install before nginx setup)
  include_recipe "neon::repo"

  repo_path = get_repo_path(node[:neonisp][:app_name])

  # Test the imageservingplatform 
  # TODO(Sunil): Add testing for the image serving platform
  #execute "nosetests --exe imageservingplatform" do
  #  cwd "#{node[:neon][:code_root]}/neonisp"
  #  user "#{node[:nginx][:user]}"
  #  action :run
  #end
  
  # Install nginx
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


  # Write the daemon service wrapper for collecting Nginx/ISP stats 
  template "/etc/init/neon-isp-metrics.conf" do
    source "neonisp_metrics_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :user => "neon",
                :group => "neon",
              })
  end
  
  # Write the crossdomain xml file
  template "#{node[:neonisp][:crossdomain_root]/crossdomain.xml}" do
    source "crossdomain.xml.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({})
  end

  service "nginx" do
    action [:enable, :start]
  end

  # start collecting the nginx/isp metrics
  service "neon-isp-metrics" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{repo_path}]", :delayed
  end
end

# Opsworks UNDEPLOY or SHUTDOWN stage
if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Delete the nginx config, which turns off the image serving platform
  file "#{node[:nginx][:dir]}/conf.d/neonisp.conf" do
    action :delete
    notifies :reload, 'service[nginx]'
  end

  # Turn off the isp metrics daemon
  service "neon-isp-metrics" do
    action :stop
  end
end
