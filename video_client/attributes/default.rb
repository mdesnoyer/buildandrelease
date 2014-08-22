include_attribute "neon::default"

# Parameters for video_client
default[:video_client][:log_dir] = "#{node[:neon][:log_dir]}/video_client"
default[:video_client][:config] = "#{node[:neon][:config_dir]}/video_client.conf"
default[:video_client][:log_file] = "#{node[:video_client][:log_dir]}/video_client.log"

# Specify the repos to user
default[:neon][:repos]["video_client"] = true
default[:neon][:repos]["core"] = true
