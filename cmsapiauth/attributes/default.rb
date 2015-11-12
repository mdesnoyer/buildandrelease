include_attribute "neon::default"
include_attribute "cmsdb::default"

# Parameters for cmsapiauth
default[:cmsapiauth][:log_dir] = "#{node[:neon][:log_dir]}/cmsapiauth"
default[:cmsapiauth][:config] = "#{node[:neon][:config_dir]}/cmsapiauth.conf"
default[:cmsapiauth][:log_file] = "#{node[:cmsapiauth][:log_dir]}/cmsapiauth.log"
default[:cmsapiauth][:access_log_file] = "#{node[:cmsapiauth][:log_dir]}/access.log"
default[:cmsapiauth][:port] = 8084 

# Specify the repos to user
default[:neon][:repos]["cmsapi_auth"] = true
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
  neon-nginx::http_spdy_module 
  neon-nginx::http_ssl_module 
)
# Force_Default is needed because these parameters are set in the nginx recipe
force_default[:nginx][:realip][:header] = "X-Forwarded-For"
force_default[:nginx][:realip][:addresses] = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
force_default[:nginx][:realip][:real_ip_recursive] = "on"
