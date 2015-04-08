include_attribute "neon::default"

# Parameters for monitoring
default[:monitoring][:log_dir] = "#{node[:neon][:log_dir]}/monitoring"
default[:monitoring][:config] = "#{node[:neon][:config_dir]}/monitoring.conf"
default[:monitoring][:log_file] = "#{node[:monitoring][:log_dir]}/monitoring.log"
default[:monitoring][:video_db_fallbackhost] = "redis1"
default[:monitoring][:video_db_layer] = "redis"

# Specify the repos to user
default[:neon][:repos]["monitoring"] = true
default[:neon][:repos]["core"] = true
