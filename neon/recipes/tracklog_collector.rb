node.default[:neon_logs][:flume_streams][:clicklog_collector_log] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "clicklog-collector-flume")
node.default[:neon_logs][:flume_streams][:clicklog_collector] = \
  get_logcollector_config(node[:neon_logs][:collector_port],
                          node[:neon][:clicklog_collector][:s3_path],
                          "clicklog",
                          4294967296, #4 GB
                          43200, # 12 hours
                          1000, # flush size
                          "bzip2",
                          'org.apache.flume.serialization.AvroEventSerializer$Builder')

include_recipe "neon_logs::flume_core"
  
