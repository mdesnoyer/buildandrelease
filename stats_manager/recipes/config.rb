# Configure the flume agent that will listen to the logs from the
# stats manager job
node.default[:neon_logs][:flume_streams][:statsmanager_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "stats_manager")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Write the configuration file for the trackserver
template node[:stats_manager][:config] do
  source "statsmanager.conf.erb"
  owner "statsmanager"
  group "statsmanager"
  mode "0644"
  variables({ 
              :batch_period => node[:stats_manager][:batch_period],
              :cluster_type => node[:stats_manager][:cluster_type],
              :cluster_ip => node[:stats_manager][:cluster_public_ip],
              :emr_key => node[:stats_manager][:emr_key],
              :log_file => node[:stats_manager][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end

