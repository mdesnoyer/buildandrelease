include_attribute "neon::default"

# Parameters for the mastermind
default[:mastermind][:config] = "#{node[:neon][:config_dir]}/mastermind.conf"
default[:mastermind][:log_file] = "#{node[:neon][:log_dir]}/mastermind.log"
