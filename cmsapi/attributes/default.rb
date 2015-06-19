include_attribute "neon::default"
include_attribute "cmsdb::default"

# Parameters for cmsapi/ supportServices
default[:cmsapi][:log_dir] = "#{node[:neon][:log_dir]}/cmsapi"
default[:cmsapi][:config] = "#{node[:neon][:config_dir]}/cmsapi.conf"
default[:cmsapi][:log_file] = "#{node[:cmsapi][:log_dir]}/cmsapi.log"
default[:cmsapi][:access_log_file] = "#{node[:cmsapi][:log_dir]}/access.log"
default[:cmsapi][:port] = 8083 
default[:cmsapi][:video_server_port] = 8081 
default[:cmsapi][:video_server_fallbackhost] = "video-server1"
default[:cmsapi][:video_server_layer] = "video_server"

# Specify the repos to user
default[:neon][:repos]["cmsapi"] = true
default[:neon][:repos]["core"] = true

# Nginx parameters
default[:nginx][:init_style] = "upstart"
default[:nginx][:large_client_header_buffers] = "8 1024000"
default[:nginx][:disable_access_log] = true
default[:nginx][:install_method] = "source"
default[:nginx][:log_dir] = "#{node[:neon][:log_dir]}/nginx"
default[:nginx][:worker_rlimit_nofile] = 65536
default[:nginx][:source][:modules] = %w(
  neon-nginx::http_realip_module
  neon-nginx::http_geoip_module
)
# Force_Default is needed because these parameters are set in the nginx recipe
force_default[:nginx][:realip][:header] = "X-Forwarded-For"
force_default[:nginx][:realip][:addresses] = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
force_default[:nginx][:realip][:real_ip_recursive] = "on"
