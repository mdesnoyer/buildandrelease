# set the flume sources
node.default[:neon_logs][:flume_streams][:click_data] = \
  get_thriftagent_config(node[:trackserver][:flume_port],
                         "tracklog",
                         "tracklog_collector",
                         node[:neon_logs][:collector_port])

node.default[:neon_logs][:flume_streams][:trackserver_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "trackserver")

node.default[:neon_logs][:flume_streams][:trackserver_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "trackserver-flume")

node.default[:neon_logs][:flume_streams][:trackserver_nginx_logs] = \
  get_fileagent_config("#{node[:nginx][:log_dir]}/error.log",
                       "trackserver-nginx")
