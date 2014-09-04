include_attribute "neon::default"

# Parameters for cmsapi/ supportServices
default[:cmsapi][:log_dir] = "#{node[:neon][:log_dir]}/cmsapi"
default[:cmsapi][:config] = "#{node[:neon][:config_dir]}/cmsapi.conf"
default[:cmsapi][:log_file] = "#{node[:cmsapi][:log_dir]}/cmsapi.log"
default[:cmsapi][:port] = 8083 
default[:cmsapi][:video_server_port] = 8081 
default[:cmsapi][:video_db_port] = 6379
default[:cmsapi][:video_db_fallbackhost] = "redis1"
default[:cmsapi][:video_db_layer] = "redis"
default[:cmsapi][:video_server_fallbackhost] = "video-server1"
default[:cmsapi][:video_server_layer] = "video_server"

# Specify the repos to user
default[:neon][:repos]["cmsapi"] = true
default[:neon][:repos]["core"] = true
