# Set parameters that flume_core uses
node.default[:neon_logs][:flume_conf_template] = "click_agent.conf.erb"
node.default[:neon_logs][:flume_service_name] = "flume-click-agent"
node.default[:neon_logs][:collector_layer] = "clicklog_aggregator"
node.default[:neon_logs][:collector_port] = 6367

include_recipe "neon_logs::flume_core"

collector_ips = get_collector_ips()

if node[:opsworks][:activity] == 'configure' then
  template "#{get_config_dir()}/flume.conf" do
    source node[:neon_logs][:flume_conf_template]
    owner  node[:neon_logs][:flume_user]
    mode "0744"
    variables({
                :agent => node[:neon_logs][:flume_agent_name],
                :collector_ips => collector_ips[:primary],
                :failover_collector_ips => collector_ips[:backup],
                :collector_port => node[:neon_logs][:collector_port],
                :hostname => node[:hostname],
                :json_http_source_port => node[:neon_logs][:json_http_source_port]
              })
    notifies :start, "service[#{node[:neon_logs][:flume_service_name]}]"
  end
end
