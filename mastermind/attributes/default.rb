include_attribute "neon::default"

# Parameters for mastermind
default[:mastermind][:log_dir] = "#{node[:neon][:log_dir]}/mastermind"
default[:mastermind][:config] = "#{node[:neon][:config_dir]}/mastermind.conf"
default[:mastermind][:log_file] = "#{node[:mastermind][:log_dir]}/mastermind.log"
default[:mastermind][:stats_host] = "54.197.233.118"
default[:mastermind][:stats_polling_delay] = 247
default[:mastermind][:video_polling_delay] = 261
default[:mastermind][:video_db_port] = 6379
default[:mastermind][:video_db_host] = "10.249.34.227"
default[:mastermind][:directive_bucket] = "neon-image-serving-directives"
default[:mastermind][:directive_filename] = "mastermind"
default[:mastermind][:publishing_period] = 300


# Specify the repos to user
default[:neon][:repos]["Mastermind"] = true
default[:neon][:repos]["core"] = true
