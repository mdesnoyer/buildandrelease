# Imageserving platform 

# Configure the flume agent that will listen to the click data and
# will watch the log file.
node.default[:neon_logs][:flume_streams][:isp_nginx_logs] = \
  get_fileagent_config("#{node[:nginx][:log_dir]}/error.log",
                       "isp-nginx")

include_recipe "neon_logs::flume_core"

# Opswork Setup Phase
if node[:opsworks][:activity] == 'setup' then
  
  # Install the neon code (Make sure to install before nginx setup)
  include_recipe "neon::repo"
  
  # Install nginx
  include_recipe "nginx::default"

  # Setup collecting system metrics
  include_recipe "neon::system_metrics"

  # Install the mail client
  package "mailutils" do
    :install
  end

  # Make directories 
  file node[:neon][:neonisp][:log_file] do
    user "#{node[:neon][:neonisp][:nginx_user]}"
    group "neon"
    mode "0644"
  end
  
  file node[:neon][:neonisp][:mastermind_download_location] do
    user "#{node[:neon][:neonisp][:nginx_user]}"
    group "neon"
    mode "0644"
  end
  
  # Collect Nginx/ISP metrics
  service "neon-isp-metrics" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action :nothing
    subscribes :restart, "git[#{node[:neon][:code_root]}]"
  end
  
  # Write the daemon service wrapper for collecting Nginx/ISP stats 
  template "/etc/init/neon-isp-metrics.conf" do
    source "neonisp_metrics_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => node[:neon][:code_root],
                :user => "neon",
                :group => "neon",
              })
  end

  # Test the imageservingplatform 
  #execute "nosetests --exe imageservingplatform" do
  #  cwd node[:neon][:code_root]
  #  user "trackserver"
  #end

  template "/etc/init/nginx-email.conf" do
    source "mail-on-restart.conf.erb"
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

  # Write the imageservingplatform configuration for nginx
  template "#{node[:nginx][:dir]}/conf.d/neonisp.conf" do
    source "neonisp_nginx.conf.erb"
    owner node['nginx']['user']
    group node['nginx']['group']
    mode "0644"
    variables({
                :port => node[:neon][:neonisp][:port],
                :mastermind_validated_filepath => node[:neon][:neonisp][:mastermind_validated_filepath],
                :mastermind_file_url => node[:neon][:neonisp][:mastermind_file_url],
                :client_expires => node[:neon][:neonisp][:client_api_expiry]
              })
    notifies :reload, 'service[nginx]'
  end
end

# Opsworks DEPLOY stage
# Since ISP is an nginx module, starting the nginx service starts ISP
# Start the monitoring script to send data

if node[:opsworks][:activity] == 'deploy' then
  service "nginx" do
    action [:enable, :start]
  end
  
  # start collecting the nginx/isp metrics
  service "neon-isp-metrics" do
    action [:enable, :start]
  end
end

# Opsworks UNDEPLOY or SHUTDOWN stage
#if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
#  # Turn off the trackserver
#  service "neonisp" do
#    action :stop
#  end
#end
