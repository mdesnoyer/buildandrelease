# set the flume sources
node.default[:neon_logs][:flume_streams][:monitoring_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "monitoring")

node.default[:neon_logs][:flume_streams][:monitoring_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "monitoring-flume")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Find the video db
Chef::Log.info "Looking for the video database in layer: #{node[:monitoring][:video_db_layer]}"
video_db_host = get_host_in_layer(node[:monitoring][:video_db_layer],
                                  node[:monitoring][:video_db_fallbackhost])
Chef::Log.info("Connecting to video db at #{video_db_host}")

repo_path = get_repo_path("monitoring")

template node[:monitoring][:config] do
  source "monitoring.conf.erb"
  owner "monitoring"
  group "monitoring"
  mode "0644"
  variables({
              :neon_root_dir => repo_path, 
              :monitoring_port => node[:monitoring][:port],
              :video_db_host => video_db_host,
              :video_db_port => node[:monitoring][:video_db_port],
              :log_file => node[:monitoring][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
