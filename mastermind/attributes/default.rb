include_attribute "neon::default"

# Parameters for mastermind
default[:mastermind][:log_dir] = "#{node[:neon][:log_dir]}/mastermind"
default[:mastermind][:config] = "#{node[:neon][:config_dir]}/mastermind.conf"
default[:mastermind][:log_file] = "#{node[:mastermind][:log_dir]}/mastermind.log"
default[:mastermind][:stats_cluster_type] = "video_click_stats"
default[:mastermind][:stats_cluster_name] = "Neon Events Cluster"
default[:mastermind][:stats_polling_delay] = 247
default[:mastermind][:video_polling_delay] = 261
default[:mastermind][:video_db_port] = 6379
default[:mastermind][:video_db_fallbackhost] = "redis1"
default[:mastermind][:video_db_layer] = "redis"
default[:mastermind][:directive_bucket] = "neon-image-serving-directives"
default[:mastermind][:directive_filename] = "mastermind"
default[:mastermind][:publishing_period] = 300


# Specify the repos to user
default[:neon][:repos]["mastermind"] = true
default[:neon][:repos]["core"] = true
