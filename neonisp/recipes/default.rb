# Imageserving platform 

include_recipe "neon::default"

# Configure the flume agent that will watch the log file.
node.default[:neon_logs][:flume_streams][:isp_nginx_logs] = \
  get_fileagent_config("#{node[:nginx][:log_dir]}/error.log",
                       "isp-nginx")

include_recipe "neon_logs::flume_core"

# Opswork Setup Phase
if node[:opsworks][:activity] == 'setup' then
  
  # Setup collecting system metrics
  include_recipe "neon::system_metrics"

  # Install the mail client
  package "mailutils" do
    :install
  end

  # Make directories 
  file node[:neonisp][:log_file] do
    user "#{node[:neonisp][:nginx_user]}"
    group "neon"
    mode "0644"
  end
  
  file node[:neonisp][:mastermind_download_location] do
    user "#{node[:neonisp][:nginx_user]}"
    group "neon"
    mode "0644"
  end
  
end

# Opsworks Configure Phase
if ['config', 'setup'].include? node[:opsworks][:activity] then

end

# Opsworks DEPLOY stage
# Since ISP is an nginx module, starting the nginx service starts ISP
# Start the monitoring script to send data

if node[:opsworks][:activity] == 'deploy' then
  # Install the neon code (Make sure to install before nginx setup)
  include_recipe "neon::repo"

  # Test the imageservingplatform 
  #execute "nosetests --exe imageservingplatform" do
  #  cwd "#{node[:neon][:code_root]}/neonisp"
  #  user "trackserver"
  #  subscribes :run, "git[#{node[:neon][:code_root]}/neonisp]", :immediately
  #end
  
  # Install nginx
  include_recipe "nginx::default"

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
                :neon_root_dir => "#{node[:neon][:code_root]}/neonisp",
                :user => "neon",
                :group => "neon",
              })
  end

  service "nginx" do
    action [:enable, :start]
  end

  
  # start collecting the nginx/isp metrics
  service "neon-isp-metrics" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{node[:neon][:code_root]}/neonisp]"
  end
end

# Opsworks UNDEPLOY or SHUTDOWN stage
if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off nginx
  service "nginx" do
    action :stop
  end

  # Turn off the isp metrics daemon
  service "neon-isp-metrics" do
    action :stop
  end
end
