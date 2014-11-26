# install hbase 
include_recipe "hadoop::hbase"

# install maven
include_recipe "maven::default"

node.default[:neon_logs][:flume_streams][:clicklog_collector_log] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "clicklog-collector-flume")

node.default[:neon_logs][:flume_streams][:clicklog_hbase] = \
  get_collector_with_hbasesink_config(node[:neon_logs][:collector_port],
                          "clicklog",
                          1073741824, #1 GB
                          10800, # 3 hours
                          1000, # flush size
                          "bzip2",
                          'org.apache.flume.sink.hdfs.AvroEventSerializer$Builder',
                          1000, # hbase batch size
                          "THUMBNAIL_TIMESTAMP_EVENTS",
                          "THUMBNAIL_EVENTS_TYPES",
                          "IMAGE_VISIBLE,IMAGE_LOAD,IMAGE_CLICK",
                          'com.neon.flume.NeonSerializer')

if node[:opsworks][:activity] == "config" then
    include_recipe "neon_logs::flume_core_config"
else
    include_recipe "neon_logs::flume_core"
end


if node[:opsworks][:activity] == "configure" then
    # Setup Hbase xml config
    Chef::Log.info "Looking for HBase in layer: #{node[:trackserver][:collector][:hbase_layer]}"
    hbase_server = nil
    hbase_layer = node[:opsworks][:layers][node[:trackserver][:collector][:hbase_layer]]
    if hbase_layer.nil?
      Chef::Log.warn "No Hbase in the layer"
    else
      hbase_layer[:instances].each do |name, instance|
        if (instance[:availability_zone] == 
            node[:opsworks][:instance][:availability_zone] or 
            hbase_server.nil?) then
          hbase_server = instance[:private_ip]
          node.default[:hbase][:hbase_site]['hbase.rootdir'] = "hdfs://#{hbase_server}:8020"
          node.default[:hbase][:hbase_site]['hbase.zookeeper.quorum'] = "#{hbase_server}"
        end
      end
    end
end


# TODO(Mark): Download the flume code and package it.
#
#   copy the file into /usr/lib/flume-ng/lib/
#
#  # include a deploy stage, check for app   
#  node[:deploy].each do |app_name, deploy|
#    if app_name != "log_collector" then
#       next
#    end
#
#    repo_path = get_repo_path("log_collector")
#
#    Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")
#    
#    # Install the neon code
#    include_recipe "neon::full_py_repo"
#
#    # Now build the jar using maven
#    # mvn clean
#    # mvn generate-sources
#    # mvn compile 
#    # mvn package
