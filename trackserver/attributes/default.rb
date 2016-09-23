include_attribute "neon::default"
include_attribute "neon::repo"
include_attribute "neonisp"

# Which repos to install
default[:neon][:repos]["track_server"] = true
default[:neon][:repos]["core"] = true

# Parameters for the trackserver
default[:trackserver][:config] = "#{node[:neon][:config_dir]}/trackserver.conf"
default[:trackserver][:log_file] = "#{node[:neon][:log_dir]}/trackserver.log"
default[:trackserver][:access_log_file] = "#{node[:neon][:log_dir]}/trackserver_access.log"
default[:trackserver][:port] = 7214 # Port being listened to internally
default[:trackserver][:external_port] = 80 # External port being listened to
default[:trackserver][:flume_port] = 6360
default[:trackserver][:backup_dir] = "/mnt/neon/trackserver/backlog"
default[:trackserver][:crossdomain_root] = "/opt/neon"

# Nginx parameters
default[:nginx][:init_style] = "upstart"
default[:nginx][:large_client_header_buffers] = "8 1024000"
default[:nginx][:disable_access_log] = true
default[:nginx][:install_method] = "source"
default[:nginx][:log_dir] = "#{node[:neon][:log_dir]}/nginx"
default[:nginx][:worker_rlimit_nofile] = 65536
default[:nginx][:source][:modules] = %w(
  neon-nginx::http_realip_module
  neon-nginx::http_geoip_module
  neonisp::nginx_ispmodule
)

# Put the image serving platform as a sub app of the trackserver
default[:neonisp][:port] = 8089
default[:neonisp][:app_name] = "track_server" 

# Parameters for the clicklog_collector
default[:trackserver][:collector][:s3_path] = "s3n://neon-tracker-logs-v2/v%{track_vers}/%{tai}/%Y/%m/%d"
default[:trackserver][:collector][:channel_dir] = "/mnt/neon/channels/clicklog"
default[:trackserver][:collector][:max_log_rolltime] = 10800 # 3 hours
default[:trackserver][:collector][:s3_serializer] = \
  "com.neon.flume.NeonAvroEventSerializer$Builder"
default[:trackserver][:collector][:do_hbase_sink] = false
default[:trackserver][:collector][:hbase_serializer] = \
  "com.neon.flume.NeonGenericSerializer"

# Hbase sink configurations
default[:trackserver][:collector][:hbase_layer] = "hbase"
default[:flume][:master][:external_zookeeper] = false
default[:flume][:master][:zookeeper_port]     = 2181
default[:hbase][:hbase_site]['hbase.cluster.distributed'] = true 
default[:hbase][:hbase_site]['zookeeper.znode.parent'] = "/mnt/hbase" 
default[:hbase][:hbase_site]['hbase.zookeeper.quorum'] = "hbase1"


# Parameters for siege
default[:trackserver][:siege][:trackserver_host] = nil

# set the desired java version
default[:java][:install_flavor] = 'oracle'
default[:java][:jdk_version] = '7'
default[:java][:oracle][:accept_oracle_download_terms] = true
