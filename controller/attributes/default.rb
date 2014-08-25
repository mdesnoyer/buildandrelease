include_attribute "neon::default"

# Parameters for controller/ supportServices
default[:controller][:log_dir] = "#{node[:neon][:log_dir]}/controller"
default[:controller][:config] = "#{node[:neon][:config_dir]}/controller.conf"
default[:controller][:log_file] = "#{node[:controller][:log_dir]}/controller.log"
default[:controller][:port] = 8081 
default[:controller][:video_db_port] = 6379
default[:controller][:video_db_fallbackhost] = "redis1"
default[:controller][:video_db_layer] = "redis"
default[:controller][:mastermind_fallbackhost] = "mastermind1"
default[:controller][:mastermind_layer] = "mastermind"
default[:controller][:mastermind_port] = 8086 
default[:controller][:cmsapi_fallbackhost] = "cmsapi1"
default[:controller][:cmsapi_layer] = "cmsapi"
default[:controller][:cmsapi_port] = 8083 

# Specify the repos to user
default[:neon][:repos]["controller"] = true
default[:neon][:repos]["core"] = true
