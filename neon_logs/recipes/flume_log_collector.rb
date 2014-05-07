node.default[:neon_logs][:flume_streams][:log_collector_log] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "log-collector-flume")
node.default[:neon_logs][:flume_streams][:log_collector] = \
  get_logcollector_config()

include_recipe "neon_logs::flume_core"
