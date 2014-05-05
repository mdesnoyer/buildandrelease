
# Java specific definitions
default["neon_logs"]["classpath"] = []
default["neon_logs"]["java_opts"] = []

# Service name
default["neon_logs"]["flume_service_name"] = "flume-ng-agent"

## Locations for flume ##
default["neon_logs"]["flume_conf_dir"] = "/etc/flume-ng/conf"
default["neon_logs"]["flume_bin"] = "/usr/bin/flume-ng"
default["neon_logs"]["flume_run_dir"] = "/var/run/flume-ng"
default["neon_logs"]["flume_log_dir"] = "/mnt/neon/logs"
default["neon_logs"]["flume_home"] = "/usr/lib/flume-ng"

# Flume agent name
default["neon_logs"]["flume_agent_name"] = node['hostname']

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
default[:neon_logs][:json_http_source_port] = 6360

## Parameters about where to output the logs ##
# The S3 path where the logs will be dropped. Can be parameterized by
# flume event headers using %{header_name} syntax. See flume
# documentation for the HDFS sink for more details.
default[:neon_logs][:s3_log_path] = "s3n://neon-server-logs/%{logtype}/%{srchost}/%Y/%m/%d"

# The compression type for writing to s3
default[:neon_logs][:s3_log_compression] = "lzo"

# The log types being written to s3
default[:neon_logs][:log_type] = "neon-logs"

# The maximum log size in bytes
default[:neon_logs][:max_log_size] = 1073741824 # 1GB

# The maximum file rollover interval in seconds
default[:neon_logs][:max_log_rolltime] = 3600 # 1 hour

# The log batch size before its pushed to s3
default[:neon_logs][:s3_flush_batch_size] = 100

# AWS keys
default["aws"]["aws_access_key"] = ENV['AWS_ACCESS_KEY_ID']
default["aws"]["secret_access_key"] = ENV['AWS_SECRET_ACCESS_KEY']
