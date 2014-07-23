# Configure the flume agent that will listen to the click data and
# will watch the log file.
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

include_recipe "neon_logs::flume_core"

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
end

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
  notifies :reload, 'service[nginx]'
end
