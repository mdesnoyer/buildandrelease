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
