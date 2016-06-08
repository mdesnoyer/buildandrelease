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
video_db_host = get_master_cmsdb_ip()
Chef::Log.info("Connecting to video db at #{video_db_host}")

repo_path = get_repo_path("video_client")

# Write the configuration file for the video client 
template node[:video_client][:config] do
  source "video_client.conf.erb"
  owner "video_client"
  group "video_client"
  mode "0644"
  variables({
              :video_db_host => video_db_host,
              :video_db_port => node[:cmsdb][:master_port],
              :max_videos_per_proc => node[:video_client][:max_videos_per_proc],
              :dequeue_period => node[:video_client][:dequeue_period],
              :notification_api_key => node[:video_client][:notification_api_key],
              :extra_workers => node[:video_client][:extra_workers],
              :video_temp_dir => node[:video_client][:video_temp_dir],
              :model_file => "#{node[:video_client][:model_data_folder]}/#{node[:video_client][:model_file]}", 
              :log_file => node[:video_client][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
