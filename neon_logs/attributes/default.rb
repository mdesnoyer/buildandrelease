
# Java specific definitions
default["neon_logs"]["classpath"] = []
default["neon_logs"]["java_opts"] = []

# Service name
default["neon_logs"]["flume_service_name"] = "flume-ng-agent"

# Flume version to install
default["neon_logs"]["flume_version"] = "1.5.0+cdh5.2.0+49-1.cdh5.2.0.p0.33~precise-cdh5.2.0"

## Locations for flume ##
default["neon_logs"]["flume_conf_dir"] = "/etc/flume-ng/conf"
default["neon_logs"]["flume_bin"] = "/usr/bin/flume-ng"
default["neon_logs"]["flume_run_dir"] = "/var/run/flume-ng"
default["neon_logs"]["flume_log_dir"] = "/var/log/flume-ng"

# User management
default[:neon_logs][:flume_user] = "flume"

# Configuring flume is done by definining logcial streams in a single
# host. For each of these streams, you must provide the following
# attribute structure:
#
# default[:neon_logs][:flume_streams][:stream_name] = { 
#   :sources => [source_names],
#   :channels => [channel_names],
#   :sinks => [sink_names],
#   :sinkgroups => [sinkgroup_names],
#   :template => template_file,
#   :template_cookbook => cookbook containing the template_file 
#                         [defaults to neon_logs]
#   :variables => {hash of variables for the template}
#
# The partial template file contains all the lines in the flume config
# except for the ones that look like:
#
# agent.sources = s1 s2
# agent.channels = c1 c2
# agent.sinks = k1 k2
#
# Your source, channel and sink names must be unique, so you might
# want to namespace them, but you must do that yourself.
default[:neon_logs][:flume_streams] = {}

# The template used to configure flume
default["neon_logs"]["flume_conf_template"] = "flume.conf.erb"

# Name of the different layers for use in OpsWorks. Must be the short name
# These are used to find hosts currently up on the different layers
default["neon_logs"]["collector_layer"] = "log-collector"

# The port that the collectors will listen on
default[:neon_logs][:collector_port] = 6366

# The port to listen for json http messages on
default[:neon_logs][:json_http_source_port] = 6362

# The port to listen for thrift messages on
default[:neon_logs][:thrift_source_port] = 6361

## Parameters about where to output the logs ##
# The S3 path where the logs will be dropped. Can be parameterized by
# flume event headers using %{header_name} syntax. See flume
# documentation for the HDFS sink for more details.
default[:neon_logs][:s3_log_path] = "s3n://neon-server-logs/%{logtype}/%{srchost}/%Y/%m/%d"

# The compression type for writing to s3
default[:neon_logs][:s3_log_compression] = "bzip2"
default[:neon_logs][:s3_output_serializer] = "TEXT"

# The log types being written to s3
default[:neon_logs][:log_type] = "neon-logs"

# The maximum log size in bytes uncompressed
default[:neon_logs][:max_log_size] = 1073741824 # 1GB

# The maximum file rollover interval in seconds
default[:neon_logs][:max_log_rolltime] = 3600 # 1 hour

# The log batch size before its pushed to s3 (doesn't actually go to s3 yet. it goes to disk until file rollover)
default[:neon_logs][:s3_flush_batch_size] = 1000
default[:neon_logs][:s3_buffer_dir] = "/mnt/neon/s3buffer"

# Maximum upload speed to s3 in KB/s
default[:neon_logs][:max_s3_upload_speed] = 12800 # 100 Mbps

# Parameters to monitor flume
default[:neon_logs][:monitor_flume] = true
default[:neon_logs][:flume_monitoring_port] = 41414
default[:neon_logs][:carbon_host] = "54.225.235.97"
default[:neon_logs][:carbon_port] = 8090

# AWS keys
default["aws"]["aws_access_key"] = ENV['AWS_ACCESS_KEY_ID']
default["aws"]["secret_access_key"] = ENV['AWS_SECRET_ACCESS_KEY']


# Overwrite the hadoop parameters
default[:hadoop][:core_site]['fs.s3.awsAccessKeyId'] = \
  node[:aws][:aws_access_key]
default[:hadoop][:core_site]['fs.s3.awsSecretAccessKey'] = \
  node[:aws][:secret_access_key]
default[:hadoop][:core_site]['fs.s3n.awsAccessKeyId'] = \
  node[:aws][:aws_access_key]
default[:hadoop][:core_site]['fs.s3n.awsSecretAccessKey'] = \
  node[:aws][:secret_access_key]
default[:hadoop][:core_site]['fs.s3.buffer.dir'] = \
  node[:neon_logs][:s3_buffer_dir]
default[:hadoop][:core_site]['fs.s3n.multipart.uploads.enabled'] = true
default[:hadoop][:core_site]['fs.s3n.multipart.uploads.block.size'] = 67108864 # 64 MB
default[:hadoop][:core_site]['fs.s3n.multipart.copy.block.size'] = 5368709120 #5GB
