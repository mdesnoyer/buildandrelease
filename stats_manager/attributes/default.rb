include_attribute "neon"
include_attribute "neon::repo"
include_attribute "neon_logs::default"

# ssh key to control Elastic Map Reduce clusters
default[:stats_manager][:emr_key] = "s3://neon-keys/emr-runner.pem"

# Install the stats manager repo
default[:neon][:repos]["stats_manager"] = true

# Locations of various files
default[:stats_manager][:log_dir] = "#{node[:neon][:log_dir]}/statsmanager"
default[:stats_manager][:config] = "#{node[:neon][:config_dir]}/statsmanager.conf"
default[:stats_manager][:log_file] = "#{node[:stats_manager][:log_dir]}/statsmanager.log"

# Pramaters for the process
default[:stats_manager][:batch_period] = 10800 # 3h for now
default[:stats_manager][:cluster_type] = "video_click_stats"
default[:stats_manager][:cluster_public_ip] = "54.210.126.245"
