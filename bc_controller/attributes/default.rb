include_attribute "neon::default"

# Parameters for bc_controller
default[:bc_controller][:log_dir] = "#{node[:neon][:log_dir]}/bc_controller"
default[:bc_controller][:config] = "#{node[:neon][:config_dir]}/bc_controller.conf"
default[:bc_controller][:log_file] = "#{node[:bc_controller][:log_dir]}/bc_controller.log"
default[:bc_controller][:port] = 8081 
default[:bc_controller][:video_db_port] = 6379
default[:bc_controller][:video_db_fallbackhost] = "redis1"
default[:bc_controller][:video_db_layer] = "redis"
default[:bc_controller][:mastermind_fallbackhost] = "mastermind1"
default[:bc_controller][:mastermind_layer] = "mastermind"
default[:bc_controller][:mastermind_port] = 8086 
default[:bc_controller][:cmsapi_fallbackhost] = "cmsapi1"
default[:bc_controller][:cmsapi_layer] = "cmsapi"
default[:bc_controller][:cmsapi_port] = 8083 

# Specify the repos to user
default[:neon][:repos]["bc_controller"] = true
default[:neon][:repos]["core"] = true
