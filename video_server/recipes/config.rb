# set the flume sources
node.default[:neon_logs][:flume_streams][:video_server_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "video_server")

node.default[:neon_logs][:flume_streams][:video_server_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "video_server-flume")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Find the video db
Chef::Log.info "Looking for the video database in layer: #{node[:video_server][:video_db_layer]}"
video_db_host = get_server_in_layer(node[:video_server][:video_db_layer], node[:video_server][:video_db_fallbackhost])
Chef::Log.info("Connecting to video db at #{video_db_host}")

repo_path = get_repo_path("video_client")
# Write the configuration file for the video server 
template node[:video_server][:config] do
  source "video_server.conf.erb"
  owner "videoserver"
  group "videoserver"
  mode "0644"
  variables({
              :neon_root_dir => repo_path, 
              :video_server_port => node[:video_server][:port],
              :video_db_host => video_db_host,
              :video_db_port => node[:video_server][:video_db_port],
              :log_file => node[:video_server][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
