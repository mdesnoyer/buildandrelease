# Set parameters that flume_core uses
node.default[:neon_logs][:flume_service_name] = "flume-log-collector"
node.default[:neon_logs][:flume_conf_template] = "log_collector.conf.erb"

include_recipe "neon_logs::flume_core"

package "hadoop" do
  action :install
end

channel_dir = get_log_dir()

if node[:opsworks][:activity] == 'configure' then
  template "#{get_config_dir()}/flume.conf" do
    source node[:neon_logs][:flume_conf_template]
    owner  node[:neon_logs][:flume_user]
    mode "0744"
    variables({
                :agent => node[:neon_logs][:flume_agent_name],
                :collector_port => node[:neon_logs][:collector_port],
                :collector_host => node[:opsworks][:instance][:private_ip],
                :s3_log_bucket => node[:neon_logs][:s3_log_bucket],
                :channel_dir => channel_dir,
                :log_type => node[:neon_logs][:log_type],
                :max_log_rolltime => node[:neon_logs][:max_log_rolltime],
                :max_log_size => node[:neon_logs][:max_log_size]
              })
  end
end
