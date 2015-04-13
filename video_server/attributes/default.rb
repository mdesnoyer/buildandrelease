include_attribute "neon::default"
include_attribute "cmsdb::default"

# Parameters for video_server
default[:video_server][:log_dir] = "#{node[:neon][:log_dir]}/video_server"
default[:video_server][:config] = "#{node[:neon][:config_dir]}/video_server.conf"
default[:video_server][:log_file] = "#{node[:video_server][:log_dir]}/video_server.log"
default[:video_server][:port] = 8081

# Specify the repos to user
default[:neon][:repos]["video_server"] = true
default[:neon][:repos]["core"] = true
