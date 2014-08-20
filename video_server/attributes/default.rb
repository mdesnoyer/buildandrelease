include_attribute "neon::default"

# Parameters for video_server
default[:video_server][:log_dir] = "#{node[:neon][:log_dir]}/video_server"
default[:video_server][:config] = "#{node[:neon][:config_dir]}/video_server.conf"
default[:video_server][:log_file] = "#{node[:video_server][:log_dir]}/video_server.log"
default[:video_server][:port] = 8081 
default[:video_server][:video_db_port] = 6379
default[:video_server][:video_db_fallbackhost] = "redis1"
default[:video_server][:video_db_layer] = "redis"

# Specify the repos to user
default[:neon][:repos]["api"] = true
