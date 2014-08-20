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

# Write the configuration file for the video server 
template node[:video_server][:config] do
  source "video_server.conf.erb"
  owner "video_server"
  group "video_server"
  mode "0644"
  variables({
              :log_file => node[:video_server][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
