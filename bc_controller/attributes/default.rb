include_attribute "neon::default"
include_attribute "cmsdb::default"
include_attribute "cmsapi::default"

# Parameters for bc_controller
default[:bc_controller][:log_dir] = "#{node[:neon][:log_dir]}/bc_controller"
default[:bc_controller][:config] = "#{node[:neon][:config_dir]}/bc_controller.conf"
default[:bc_controller][:ingester_config] = "#{node[:neon][:config_dir]}/bc_ingester.conf"
default[:bc_controller][:cnn_ingester_config] = "#{node[:neon][:config_dir]}/cnn_ingester.conf"
default[:bc_controller][:fox_ingester_config] = "#{node[:neon][:config_dir]}/fox_ingester.conf"
default[:bc_controller][:log_file] = "#{node[:bc_controller][:log_dir]}/bc_controller.log"
default[:bc_controller][:ingester_log_file] = "#{node[:bc_controller][:log_dir]}/bc_ingester.log"
default[:bc_controller][:cnn_ingester_log_file] = "#{node[:bc_controller][:log_dir]}/cnn_ingester.log"
default[:bc_controller][:fox_ingester_log_file] = "#{node[:bc_controller][:log_dir]}/fox_ingester.log"
default[:bc_controller][:cnn_service_name] = "cnn"
default[:bc_controller][:bc_service_name] = "brightcove"
default[:bc_controller][:fox_service_name] = "fox"
default[:bc_controller][:port] = 8081 
default[:bc_controller][:mastermind_fallbackhost] = "mastermind1"
default[:bc_controller][:mastermind_layer] = "mastermind"
default[:bc_controller][:mastermind_port] = 8086 
default[:bc_controller][:cmsapi_fallbackhost] = "cmsapi1"
default[:bc_controller][:cmsapi_layer] = "cmsapi"
default[:bc_controller][:ingester_poll_period] = 293
default[:bc_controller][:max_vids_in_new_account] = 100
default[:bc_controller][:cmsapi_user] = "admin_neon_ingester"
default[:bc_controller][:cmsapi_pass] = nil

# Specify the repos to user
default[:neon][:repos]["brightcove_controller"] = true
default[:neon][:repos]["core"] = true
