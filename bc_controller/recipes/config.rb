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
Chef::Log.info "Looking for the video database in layer: #{node[:bc_controller][:video_db_layer]}"
video_db_host = nil
video_db_layer = node[:opsworks][:layers][node[:bc_controller][:video_db_layer]]
if video_db_layer.nil?
  Chef::Log.warn "No video db instances available. Falling back to host #{node[:bc_controller][:video_db_fallbackhost]}"
  video_db_host = node[:bc_controller][:video_db_fallbackhost]
else
  video_db_layer[:instances].each do |name, instance|
    if (instance[:availability_zone] == 
        node[:opsworks][:instance][:availability_zone] or 
        video_db_host.nil?) then
      video_db_host = instance[:private_ip]
    end
  end
end
Chef::Log.info("Connecting to video db at #{video_db_host}")

# Find Mastermind
Chef::Log.info "Looking for the Mastermind in layer: #{node[:bc_controller][:mastermind_layer]}"
mastermind_host = nil
mastermind_layer = node[:opsworks][:layers][node[:bc_controller][:mastermind]]
if mastermind_layer.nil?
  Chef::Log.warn "No mastermind instances available. Falling back to host #{node[:bc_controller][:mastermind_fallbackhost]}"
  mastermind_host = node[:bc_controller][:mastermind_fallbackhost]
else
  mastermind_layer[:instances].each do |name, instance|
    if (instance[:availability_zone] == 
        node[:opsworks][:instance][:availability_zone] or 
        mastermind_host.nil?) then
      mastermind_host = instance[:private_ip]
    end
  end
end
Chef::Log.info("Connecting to mastermind at #{mastermind_host}")

# Find Services/ CMS API server 
Chef::Log.info "Looking for the CMS API in layer: #{node[:bc_controller][:cmsapi_layer]}"
cmsapi_host = nil
cmsapi_layer = node[:opsworks][:layers][node[:bc_controller][:cmsapi]]
if cmsapi_layer.nil?
  Chef::Log.warn "No cmsapi instances available. Falling back to host #{node[:bc_controller][:cmsapi_fallbackhost]}"
  cmsapi_host = node[:bc_controller][:cmsapi_fallbackhost]
else
  cmsapi_layer[:instances].each do |name, instance|
    if (instance[:availability_zone] == 
        node[:opsworks][:instance][:availability_zone] or 
        cmsapi_host.nil?) then
       cmsapi_host = instance[:private_ip]
    end 
  end   
end 
Chef::Log.info("Connecting to cmsapi at #{cmsapi_host}")

# Write the configuration file for the video server 
template node[:bc_controller][:config] do
  source "bc_controller.conf.erb"
  owner "bc_controller"
  group "bc_controller"
  mode "0644"
  variables({
              :bc_controller_port => node[:bc_controller][:port],
              :video_db_host => video_db_host,
              :video_db_port => node[:bc_controller][:video_db_port],
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
