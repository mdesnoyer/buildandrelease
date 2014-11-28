node.default[:neon_logs][:flume_streams][:clicklog_collector_log] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "clicklog-collector-flume")

node.default[:neon_logs][:flume_streams][:clicklog_hbase] = {\
  :sources => ["clicklog_s"],
  :channels => ["s3_c", "hbase_c"],
  :sinks => ["s3_k", "hbase_k"],
  :sinkgroups => [],
  :template => 'collector_flume.conf.erb',
  :variables => {
    :cs => "clicklog_s",
    :cc => "s3_c",
    :ck => "s3_k",
    :hc => "hbase_c",
    :hk => "hbase_k",
    :collector_port => node[:neon_logs][:collector_port],
    :collector_host => node[:opsworks][:instance][:private_ip],
    :s3_log_path => node[:trackserver][:collector][:s3_path],
    :max_log_size => 1073741824, #1 GB
    :max_log_rolltime => node[:trackserver][:collector][:max_log_rolltime],
    :s3_flush_batch_size => 1000,
    :compression => "bzip2",
    :log_type => "clicklog",
    :s3_output_serializer => node[:trackserver][:collector][:s3_serializer],
    :hbase_flush_batch_size => 10000,
    :hbase_table => "THUMBNAIL_TIMESTAMP_EVENTS",
    :hbase_cf => "THUMBNAIL_EVENTS_TYPES",
    :hbase_serializer => node[:trackserver][:collector][:hbase_serializer],
  }
}

if node[:opsworks][:activity] == "configure" then
  # Setup Hbase xml config
  Chef::Log.info("Looking for HBase in layer: "\
                 "#{node[:trackserver][:collector][:hbase_layer]}")
  hbase_server = nil
  hbase_layer = node[:opsworks][:layers][
    node[:trackserver][:collector][:hbase_layer]]
  if hbase_layer.nil?
    Chef::Log.warn "No Hbase in the layer"
  else
    hbase_layer[:instances].each do |name, instance|
      if (instance[:availability_zone] == 
          node[:opsworks][:instance][:availability_zone] or 
          hbase_server.nil?) then
        hbase_server = instance[:private_ip]
        node.default[:hbase][:hbase_site]['hbase.rootdir'] = \
          "hdfs://#{hbase_server}:8020"
        node.default[:hbase][:hbase_site]['hbase.zookeeper.quorum'] = \
          "#{hbase_server}"
      end
    end
  end

  include_recipe "neon_logs::flume_core_config"
end
