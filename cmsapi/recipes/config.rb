# set the flume sources
node.default[:neon_logs][:flume_streams][:cmsapi_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "cmsapi")

node.default[:neon_logs][:flume_streams][:cmsapi_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "cmsapi-flume")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Find the video db
video_db_host = get_master_cmsdb_ip()
Chef::Log.info("Connecting to video db at #{video_db_host}")

# Find the video server 
Chef::Log.info "Looking for the video server in layer: #{node[:cmsapi][:video_server_layer]}"
video_server_host = get_host_in_layer(node[:cmsapi][:video_server_layer],
                                      node[:cmsapi][:video_server_fallbackhost])

# Write the configuration file for CMS API 
template node[:cmsapi][:config] do
  source "cmsapi.conf.erb"
  owner "cmsapi"
  group "cmsapi"
  mode "0644"
  variables({
              :video_server_port => node[:cmsapi][:video_server_port],
              :video_server_host => video_server_host, 
              :cmsapi_port => node[:cmsapi][:port],
              :video_db_host => video_db_host,
              :video_db_port => node[:cmsdb][:master_port],
              :log_file => node[:cmsapi][:log_file],
              :access_log_file => node[:cmsapi][:access_log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end

# Write the configuration file for CMS API 
template node[:cmsapiv2][:config] do
  source "cmsapiv2.conf.erb"
  owner "cmsapi"
  group "cmsapi"
  mode "0644"
  variables({
              :video_server_port => node[:cmsapi][:video_server_port],
              :video_server_host => video_server_host, 
              :cmsapiv2_port => node[:cmsapiv2][:port],
              :cmsapiv1_port => node[:cmsapi][:port],
              :video_db_host => video_db_host,
              :video_db_port => node[:cmsdb][:master_port],
              :log_file => node[:cmsapiv2][:log_file],
              :access_log_file => node[:cmsapiv2][:access_log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end

cmsapi_exists = File.exists?("/etc/init/cmsapi.conf")

if cmsapi_exists then
  # Specify the service for chef so that they can be restarted.
  service "cmsapi" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action :nothing
  end

  service "nginx" do
    action :nothing
  end
end

cmsapiv2_exists = File.exists?("/etc/init/cmsapiv2.conf")

if cmsapiv2_exists then
  # Specify the service for chef so that they can be restarted.
  service "cmsapiv2" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action :nothing
  end

  service "nginx" do
    action :nothing
  end
end

include_recipe "neon-nginx::commons_dir"

# Write the configuration for nginx
template "#{node[:nginx][:dir]}/conf.d/cmsapi.conf" do
  source "cmsapi_nginx.conf.erb"
  owner node['nginx']['user']
  group node['nginx']['group']
  mode "0644"
  variables({
              :service_port_v1 => node[:cmsapi][:port], 
              :service_port_v2 => node[:cmsapiv2][:port], 
              :frontend_port => 80 
            })
  if cmsapi_exists || cmsapiv2_exists
    notifies :reload, 'service[nginx]', :delayed
  end
end
