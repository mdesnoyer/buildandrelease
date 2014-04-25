# Set parameters that flume_core uses
node.default[:neon_logs][:flume_service_name] = "flume-log-collector"
node.default[:neon_logs][:flume_conf_template] = "log_collector.conf.erb"
node.default[:hadoop][:core_site]['fs.s3.awsAccessKeyId'] = \
  node[:aws][:aws_access_key]
node.default[:hadoop][:core_site]['fs.s3.awsSecretAccessKey'] = \
  node[:aws][:secret_access_key]
node.default[:hadoop][:core_site]['fs.s3n.awsAccessKeyId'] = \
  node[:aws][:aws_access_key]
node.default[:hadoop][:core_site]['fs.s3n.awsSecretAccessKey'] = \
  node[:aws][:secret_access_key]

include_recipe "neon_logs::flume_core"

if node[:opsworks][:activity] == 'setup' then
  include_recipe "hadoop"
end

channel_dir = get_log_dir()

if node[:opsworks][:activity] == 'configure' then
  safe_aws_key = escape_aws_key(node[:aws][:aws_access_key])
  safe_aws_secret_key = escape_aws_key(node[:aws][:secret_access_key])

  template "#{get_config_dir()}/flume.conf" do
    source node[:neon_logs][:flume_conf_template]
    owner  node[:neon_logs][:flume_user]
    mode "0644"
    variables({
                :agent => node[:neon_logs][:flume_agent_name],
                :collector_port => node[:neon_logs][:collector_port],
                :collector_host => node[:opsworks][:instance][:private_ip],
                :s3_log_bucket => node[:neon_logs][:s3_log_bucket],
                :channel_dir => channel_dir,
                :log_type => node[:neon_logs][:log_type],
                :max_log_rolltime => node[:neon_logs][:max_log_rolltime],
                :max_log_size => node[:neon_logs][:max_log_size],
                :hostname => node[:hostname]
              })
    notifies :start, "service[#{node[:neon_logs][:flume_service_name]}]"
  end
end
