# Set parameters that flume_core uses
node.default[:hadoop][:core_site]['fs.s3.awsAccessKeyId'] = \
  node[:aws][:aws_access_key]
node.default[:hadoop][:core_site]['fs.s3.awsSecretAccessKey'] = \
  node[:aws][:secret_access_key]
node.default[:hadoop][:core_site]['fs.s3n.awsAccessKeyId'] = \
  node[:aws][:aws_access_key]
node.default[:hadoop][:core_site]['fs.s3n.awsSecretAccessKey'] = \
  node[:aws][:secret_access_key]

node.default[:neon_logs][:flume_streams][:clicklog_collector_log] = \
  get_fileagent_config("#{get_log_dir()}/flume.init.log",
                       "clicklog-collector-flume")
node.default[:neon_logs][:flume_streams][:clicklog_collector] = \
  get_logcollector_config(node[:neon_logs][:collector_port],
                          node[:neon][:clicklog_collector][:s3_path],
                          "clicklog",
                          node[:neon][:clicklog_collector][:channel_dir],
                          2147483648, # 2GB
                          3600, # 1 hour
                          1000, # flush size
                          "bzip2")

include_recipe "neon_logs::flume_core"

if node[:opsworks][:activity] == 'setup'
  directory node[:neon][:clicklog_collector][:channel_dir] do
    owner node[:neon_logs][:flume_user]
    action :create
    mode "0755"
    recursive true
  end
end
  
