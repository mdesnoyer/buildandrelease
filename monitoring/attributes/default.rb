include_attribute "neon::default"
include_attribute "cmsdb::default"

# Parameters for monitoring
default[:monitoring][:log_dir] = "#{node[:neon][:log_dir]}/monitoring"
default[:monitoring][:config] = "#{node[:neon][:config_dir]}/monitoring.conf"
default[:monitoring][:log_file] = "#{node[:monitoring][:log_dir]}/monitoring.log"
default[:monitoring][:account] = "159"
default[:monitoring][:api_key] = "3yd7b8vmrj67b99f7a8o1n30"
default[:monitoring][:cmsapi_user] = nil
default[:monitoring][:cmsapi_pass] = nil
default[:monitoring][:sleep] = 10

# Specify the repos to use
default[:neon][:repos]["monitoring"] = true
default[:neon][:repos]["core"] = true
