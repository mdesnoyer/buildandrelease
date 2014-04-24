# Set parameters that flume_core uses
node.default[:neon_logs][:flume_conf_template] = "filelog_agent.conf.erb"
node.default[:neon_logs][:flume_service_name] = "flume-filelog-agent"

include_recipe "neon_logs::flume_core"

collector_ips = get_collector_ips()
service_bin = get_service_bin()

if node[:opsworks][:activity] == 'configure' then
  template "#{get_config_dir()}/flume.conf" do
    source node[:neon_logs][:flume_conf_template]
    owner  node[:neon_logs][:flume_user]
    mode "0744"
    variables({
                :agent => node[:neon_logs][:flume_agent_name],
                :source_file => node[:neon_logs][:log_source_file],
                :collector_ips => collector_ips[:primary],
                :failover_collector_ips => collector_ips[:backup],
                :collector_port => node[:neon_logs][:collector_port],
                :hostname => node[:hostname]
              })
    notifies :start, "services[#{service_bin}]"
  end
end
