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
Chef::Log.info "Looking for the video database in layer: #{node[:mastermind][:video_db_layer]}"
video_db_nost = nil
video_db_layer = node[:opsworks][:layers][node[:mastermind][:video_db_layer]]
if video_db_layer.nil?
  Chef::Log.warn "No video db instances available. Falling back to host #{node[:mastermind][:video_db_fallbackhost]}"
  video_db_host = node[:mastermind][:video_db_fallbackhost]
else
  video_db_layer.each do |name, instance|
    if (instance[:availability_zone] == 
        node[:opsworks][:instance][:availability_zone] or 
        video_db_host.nil?) then
      video_db_host = instance[:private_ip]
    end
  end
end
Chef::Log.info("Connecting mastermind to video db at #{video_db_host}"

# Write the configuration file for the mastermind
template node[:mastermind][:config] do
  source "mastermind.conf.erb"
  owner "mastermind"
  group "mastermind"
  mode "0644"
  variables({
              :stats_host => node[:mastermind][:stats_host],
              :stats_polling_delay => node[:mastermind][:stats_polling_delay],
              :video_polling_delay => node[:mastermind][:video_polling_delay],
              :directive_bucket => node[:mastermind][:directive_bucket],
              :directive_filename => node[:mastermind][:directive_filename],
              :publishing_period => node[:mastermind][:publishing_period],
              :video_db_host => video_db_host,
              :video_db_port => node[:mastermind][:video_db_port],
              :log_file => node[:mastermind][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
