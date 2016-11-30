include_attribute "neon::default"
include_attribute "cmsdb::default"

# Parameters for mastermind
default[:mastermind][:log_dir] = "#{node[:neon][:log_dir]}/mastermind"
default[:mastermind][:config] = "#{node[:neon][:config_dir]}/mastermind.conf"
default[:mastermind][:log_file] = "#{node[:mastermind][:log_dir]}/mastermind.log"
default[:mastermind][:tmp_dir] = "/mnt/tmp/mastermind"
default[:mastermind][:stats_cluster_type] = "video_click_stats"
default[:mastermind][:stats_cluster_name] = "Neon Event Cluster"
default[:mastermind][:stats_polling_delay] = 247
default[:mastermind][:video_polling_delay] = 261
default[:mastermind][:incr_stats_layer] = "hbase"
default[:mastermind][:incr_stats_fallbackhost] = "hbase1"
default[:mastermind][:directive_bucket] = "neon-image-serving-directives-hold"
default[:mastermind][:directive_filename] = "mastermind"
default[:mastermind][:publishing_period] = 300
default[:mastermind][:expiry_buffer] = 30
default[:mastermind][:serving_update_delay] = 120
default[:mastermind][:send_callbacks] = 0
default[:mastermind][:isp_host] = "isp-103281060.us-east-1.elb.amazonaws.com"

# Specify the repos to user
default[:neon][:repos]["mastermind"] = true
default[:neon][:repos]["core"] = true
