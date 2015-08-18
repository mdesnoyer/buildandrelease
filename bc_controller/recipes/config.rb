# set the flume sources
node.default[:neon_logs][:flume_streams][:bc_controller_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "bc_controller")

node.default[:neon_logs][:flume_streams][:bc_controller_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "bc_controller-flume")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Find the video db
video_db_host = get_master_cmsdb_ip()
Chef::Log.info("Connecting to video db at #{video_db_host}")

# Find Mastermind
Chef::Log.info "Looking for the Mastermind in layer: #{node[:bc_controller][:mastermind_layer]}"
mastermind_host = get_host_in_layer(node[:bc_controller][:mastermind_layer],
                                    node[:bc_controller][:mastermind_fallbackhost])
Chef::Log.info("Connecting to mastermind at #{mastermind_host}")

# Find Services/ CMS API server 
Chef::Log.info "Looking for the CMS API in layer: #{node[:bc_controller][:cmsapi_layer]}"
cmsapi_host = get_host_in_layer(node[:bc_controller][:cmsapi_layer],
                                node[:bc_controller][:cmsapi_fallbackhost])
Chef::Log.info("Connecting to cmsapi at #{cmsapi_host}")

# Write the configuration file 
template node[:bc_controller][:config] do
  source "bc_controller.conf.erb"
  owner "bc_controller"
  group "bc_controller"
  mode "0644"
  variables({
              :bc_controller_port => node[:bc_controller][:port],
              :video_db_host => video_db_host,
              :video_db_port => node[:cmsdb][:master_port],
              :mastermind_host => mastermind_host,
              :mastermind_port => node[:bc_controller][:mastermind_port],
              :cmsapi_host => cmsapi_host, 
              :cmsapi_port => node[:bc_controller][:cmsapi_port], 
              :log_file => node[:bc_controller][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end

template node[:bc_controller][:ingester_config] do
  source "bc_ingester.conf.erb"
  owner "bc_controller"
  group "bc_controller"
  mode "0644"
  variables({
              :video_db_host => video_db_host,
              :video_db_port => node[:cmsdb][:master_port],
              :cmsapi_host => cmsapi_host, 
              :cmsapi_port => node[:cmsapi][:port], 
              :log_file => node[:bc_controller][:ingester_log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
