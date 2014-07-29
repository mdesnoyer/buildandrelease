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

# TODO(sunil): set video db host to the layer location when we put the
# db on opsworks

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
              :video_db_host => node[:mastermind][:video_db_host],
              :video_db_port => node[:mastermind][:video_db_port],
              :log_file => node[:mastermind][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
