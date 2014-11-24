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


# NOTE: Add the right collector channel to the hbase sink, currently 
# it is set as lc_clicklog_c channel, if you modify the namspace, please update
# the channel name below
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
    
    # Setup Hbase xml config
    Chef::Log.info "Looking for HBase in layer: #{node[:trackserver][:collector][:hbase_layer]}"
    hbase_server = nil
    hbase_layer = node[:opsworks][:layers][[:trackserver][:collector][:hbase_layer]]
    if hbase_layer.nil?
      Chef::Log.warn "No Hbase in the layer"
    else
      hbase_layer[:instances].each do |name, instance|
        if (instance[:availability_zone] == 
            node[:opsworks][:instance][:availability_zone] or 
            hbase_server.nil?) then
          hbase_server = instance[:private_ip]
          node[:hbase][:hbase_site]['hbase.rootdir'] = "hdfs://#{hbase_server}:8020"
          node[:hbase][:hbase_site]['hbase.zookeeper.quorum'] = "#{hbase_server}"
        end
      end
    end

else
  include_recipe "neon_logs::flume_core"
  # install hbase 
  include_recipe "hadoop::hbase"

  # install maven
  include_recipe "maven::default"

  # include a deploy stage, check for app   
end
