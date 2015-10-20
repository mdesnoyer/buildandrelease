# set the flume sources
node.default[:neon_logs][:flume_streams][:mastermind_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "mastermind")

node.default[:neon_logs][:flume_streams][:mastermind_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "mastermind-flume")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Find the video db
video_db_host = get_master_cmsdb_ip()
Chef::Log.info("Connecting mastermind to video db at #{video_db_host}")

# Get the hbase database
incr_stats_host = get_first_host_in_layer(node[:mastermind][:incr_stats_layer],
                                          node[:mastermind][:incr_stats_fallbackhost])
Chef::Log.info("Connecting mastermind to incremental stats db #{incr_stats_host}")

# Write the configuration file for the mastermind
template node[:mastermind][:config] do
  source "mastermind.conf.erb"
  owner "mastermind"
  group "mastermind"
  mode "0644"
  variables({
              :stats_cluster_type => node[:mastermind][:stats_cluster_type],
              :stats_cluster_name => node[:mastermind][:stats_cluster_name],
              :stats_polling_delay => node[:mastermind][:stats_polling_delay],
              :video_polling_delay => node[:mastermind][:video_polling_delay],
              :directive_bucket => node[:mastermind][:directive_bucket],
              :directive_filename => node[:mastermind][:directive_filename],
              :publishing_period => node[:mastermind][:publishing_period],
              :expiry_buffer => node[:mastermind][:expiry_buffer],
              :serving_update_delay => node[:mastermind][:serving_update_delay],
              :video_db_host => video_db_host,
              :video_db_port => node[:cmsdb][:master_port],
              :incr_stats_host => incr_stats_host,
              :log_file => node[:mastermind][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
              :tmp_dir => node[:mastermind][:tmp_dir],
              :send_callbacks => node[:mastermind][:send_callbacks]
            })
end
