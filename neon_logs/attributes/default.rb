
# Java specific definitions
default["neon_logs"]["classpath"] = []
default["neon_logs"]["java_opts"] = []

# Service name
default["neon_logs"]["flume_service_name"] = "flume-ng-agent"

## Locations for flume ##
default["neon_logs"]["flume_conf_dir"] = "/etc/flume-ng/conf"
default["neon_logs"]["flume_bin"] = "/usr/bin/flume-ng"
default["neon_logs"]["flume_run_dir"] = "/var/run/flume-ng"
default["neon_logs"]["flume_log_dir"] = "/var/log"
default["neon_logs"]["flume_home"] = "/usr/lib/flume-ng"

# The template used to configure flume
default["neon_logs"]["flume_conf_template"] = "filelog_agent.conf.erb"

# Flume agent name
default["neon_logs"]["flume_agent_name"] = lazy { node['hostname'] }

# Name of the different layers for use in OpsWorks. Must be the short name
# These are used to find hosts currently up on the different layers
default["neon_logs"]["collector_layer"] = "log-collector"

# User management
default[:neon_logs][:flume_user] = "flume"

# The port that the collectors will listen on
default[:neon_logs][:collector_port] = 6366

## Parameters about where to output the logs ##
# The S3 bucket where the logs will be dropped
default[:neon_logs][:s3_log_bucket] = "neon-server-logs"

# The log types being written to s3
default[:neon_logs][:log_type] = "neon-logs"

# The maximum log size in bytes
default[:neon_logs][:max_log_size] = 1073741824 # 1GB

# The maximum file rollover interval in seconds
default[:neon_logs][:max_log_rolltime] = 3600 # 1 hour

# The system file to listen to for logs
default[:neon_logs][:log_source_file] = "/mnt/logs/neon/neon.log"

# AWS keys
default["aws"]["aws_access_key"] = ENV['AWS_ACCESS_KEY_ID']
default["aws"]["secret_access_key"] = ENV['AWS_SECRET_ACCESS_KEY']
