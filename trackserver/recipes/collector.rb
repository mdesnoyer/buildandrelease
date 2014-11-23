node.default[:neon_logs][:flume_streams][:clicklog_collector_log] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "clicklog-collector-flume")
node.default[:neon_logs][:flume_streams][:clicklog_collector] = \
  get_logcollector_config(node[:neon_logs][:collector_port],
                          node[:trackserver][:collector][:s3_path],
                          "clicklog",
                          1073741824, #1 GB
                          10800, # 3 hours
                          1000, # flush size
                          "bzip2",
                          'org.apache.flume.sink.hdfs.AvroEventSerializer$Builder')


# Add the right collector channel
node.default[:neon_logs][:flume_streams][:clicklog_hbase] = \
  get_hbasesink_config(node[:neon_logs][:collector_port],
                          "hbasesink",
                          "lc_clicklog_c", # channel name from above
                          1,
                          "THUMBNAIL_TIMESTAMP_EVENTS",
                          "THUMBNAIL_EVENTS_TYPES",
                          "IMAGE_VISIBLE,IMAGE_LOAD,IMAGE_CLICK",
                          'com.neon.flume.NeonSerializer')

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
  # install hbase 
  include recipe "hadoop::hbase"

  # install maven
  # include a deploy stage, check for app   
end
  
