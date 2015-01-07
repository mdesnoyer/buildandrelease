Chef::Log.info("Looking for HBase in layer: "\
               "#{node[:trackserver][:collector][:hbase_layer]}")
hbase_server = get_host_in_layer(node[:trackserver][:collector][:hbase_layer], nil)

node.default[:neon_logs][:flume_streams][:clicklog_collector_log] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "clicklog-collector-flume")

do_hbase_sink = node[:trackserver][:collector][:do_hbase_sink] and not hbase_server.nil?

node.default[:neon_logs][:flume_streams][:clicklog_hbase] = {\
  :sources => ["clicklog_s"],
  :channels => node[:trackserver][:collector][:do_hbase_sink] ? ["s3_c", "hbase_c"] : ["s3_c"],
  :sinks => node[:trackserver][:collector][:do_hbase_sink] ? ["s3_k", "hbase_k"] : ["s3_k"],
  :sinkgroups => [],
  :template => 'collector_flume.conf.erb',
  :template_cookbook => 'trackserver',
  :variables => {
    :do_hbase_sink => do_hbase_sink,
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
    :hbase_table => "THUMBNAIL_TIMESTAMP_EVENT_COUNTS",
    :hbase_cf => "evts",
    :hbase_serializer => node[:trackserver][:collector][:hbase_serializer],
    :zookeeper_quorum => "#{hbase_server}:#{node[:flume][:master][:zookeeper_port]}",
    :znode_parent => node[:hbase][:hbase_site]['zookeeper.znode.parent'],
  }
}

if node[:opsworks][:activity] == "configure" then
  # install hbase libraries
  include_recipe "hadoop::hbase"

  include_recipe "neon_logs::flume_core_config"

  service node[:neon_logs][:flume_service_name] do
    action :nothing
    subscribes :restart, "template[/etc/hbase/#{node['hbase']['conf_dir']}/hbase-site.xml]"
  end
end
