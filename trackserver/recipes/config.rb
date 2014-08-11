# set the flume sources
node.default[:neon_logs][:flume_streams][:click_data] = \
  get_thriftagent_config(node[:trackserver][:flume_port],
                         "tracklog",
                         "tracklog_collector",
                         node[:neon_logs][:collector_port])

node.default[:neon_logs][:flume_streams][:trackserver_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "trackserver")

node.default[:neon_logs][:flume_streams][:trackserver_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "trackserver-flume")

node.default[:neon_logs][:flume_streams][:trackserver_nginx_logs] = \
  get_fileagent_config("#{node[:nginx][:log_dir]}/error.log",
                       "trackserver-nginx")

if node[:opsworks][:activity] == "config" then
  include_recipe "neonisp::config"
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

trackserver_exists = File.exists?("/etc/init/neon-trackserver.conf")

if trackserver_exists then
  # Specify the service for chef so that they can be restarted.
  service "neon-trackserver" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action :nothing
  end

  service "nginx" do
    action :nothing
  end
end

# Write the configuration file for the trackserver
template node[:trackserver][:config] do
  source "trackserver.conf.erb"
  owner "trackserver"
  group "trackserver"
  mode "0644"
  variables({
              :port => node[:trackserver][:port],
              :flume_port => node[:trackserver][:flume_port],
              :backup_dir => node[:trackserver][:backup_dir],
              :log_file => node[:trackserver][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
  if trackserver_exists
    notifies :restart, 'service[neon-trackserver]', :delayed
  end
end

include_recipe "neon-nginx::commons_dir"

# Write the configuration for nginx
template "#{node[:nginx][:dir]}/conf.d/trackserver.conf" do
  source "trackserver_nginx.conf.erb"
  owner node['nginx']['user']
  group node['nginx']['group']
  mode "0644"
  variables({
              :service_port => node[:trackserver][:port],
              :frontend_port => node[:trackserver][:external_port]
            })
  if trackserver_exists
    notifies :reload, 'service[nginx]', :delayed
  end
end
