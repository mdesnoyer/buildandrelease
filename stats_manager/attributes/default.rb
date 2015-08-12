include_attribute "neon"
include_attribute "neon::repo"
include_attribute "neon_logs::default"

# ssh key to control Elastic Map Reduce clusters
default[:stats_manager][:emr_key] = "s3://neon-keys/emr-runner-2015.pem"

# Install the stats manager repo
default[:neon][:repos]["stats_manager"] = true

# Locations of various files
default[:stats_manager][:log_dir] = "#{node[:neon][:log_dir]}/statsmanager"
default[:stats_manager][:config] = "#{node[:neon][:config_dir]}/statsmanager.conf"
default[:stats_manager][:log_file] = "#{node[:stats_manager][:log_dir]}/statsmanager.log"
default[:stats_manager][:service_enabled] = true

# Pramaters for the process
default[:stats_manager][:batch_period] = 10800 # 3h for now
default[:stats_manager][:cluster_name] = "#{node[:opsworks][:stack][:name]} (#{node[:opsworks][:instance][:aws_instance_id]})"
default[:stats_manager][:cluster_type] = "video_click_stats"
default[:stats_manager][:cluster_public_ip] = "54.210.126.245" # Production US-East
default[:stats_manager][:cluster_subnet_id] = "subnet-74c10003" # Stats Cluster us-east-1c (10.0.128.0/17) | vpc-90ad09f5
default[:stats_manager][:cluster_log_uri] = "s3://neon-cluster-logs/"
default[:stats_manager][:max_task_instances] = 10
