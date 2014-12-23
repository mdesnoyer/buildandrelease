# set the flume sources
node.default[:neon_logs][:flume_streams][:video_client_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "video_client")

node.default[:neon_logs][:flume_streams][:video_client_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "video_client-flume")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Find the video db
Chef::Log.info "Looking for the video database in layer: #{node[:video_client][:video_db_layer]}"
video_db_host = get_server_in_layer(node[:video_client][:video_db_layer], node[:video_client][:video_db_fallbackhost])
Chef::Log.info("Connecting to video db at #{video_db_host}")

# Find the video server 
Chef::Log.info "Looking for the video server in layer: #{node[:video_client][:video_server_layer]}"
video_server_host = get_server_in_layer(node[:video_client][:video_server_layer], node[:video_client][:video_server_fallbackhost])

repo_path = get_repo_path("video_client")

# Write the configuration file for the video client 
template node[:video_client][:config] do
  source "video_client.conf.erb"
  owner "video_client"
  group "video_client"
  mode "0644"
  variables({
              :video_server_host => video_server_host,
              :video_server_port => node[:video_client][:video_server_port],
              :video_db_host => video_db_host,
              :video_db_port => node[:video_client][:video_db_port],
              :max_videos_per_proc => node[:video_client][:max_videos_per_proc],
              :dequeue_period => node[:video_client][:dequeue_period],
              :notification_api_key => node[:video_client][:notification_api_key],
              :server_auth => node[:video_client][:server_auth],
              :extra_workers => node[:video_client][:extra_workers],
              :video_temp_dir => node[:video_client][:video_temp_dir],
              :model_file => "#{node[:neon][:home]}/#{node[:video_client][:model_file]}", 
              :log_file => node[:video_client][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
