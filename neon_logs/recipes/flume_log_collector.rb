# Set parameters that flume_core uses
node.default[:hadoop][:core_site]['fs.s3.awsAccessKeyId'] = \
  node[:aws][:aws_access_key]
node.default[:hadoop][:core_site]['fs.s3.awsSecretAccessKey'] = \
  node[:aws][:secret_access_key]
node.default[:hadoop][:core_site]['fs.s3n.awsAccessKeyId'] = \
  node[:aws][:aws_access_key]
node.default[:hadoop][:core_site]['fs.s3n.awsSecretAccessKey'] = \
  node[:aws][:secret_access_key]

node.default[:neon_logs][:flume_streams][:log_collector_log] = \
  get_fileagent_config("#{get_log_dir()}/flume.init.log",
                       "log-collector-flume")
node.default[:neon_logs][:flume_streams][:log_collector] = \
  get_logcollector_config()

include_recipe "neon_logs::flume_core"
