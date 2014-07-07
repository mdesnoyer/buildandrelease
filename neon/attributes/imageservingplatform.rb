# Nginx parameters
#default['nginx']['source']['version'] = '1.4.7'
default[:nginx][:user] = "neon"
default[:nginx][:init_style] = "upstart"
default[:nginx][:large_client_header_buffers] = "8 1024000"
default[:nginx][:disable_access_log] = true
default[:nginx][:install_method] = "source"
default[:nginx][:log_dir] = "#{node[:neon][:log_dir]}/nginx"
default[:nginx][:worker_rlimit_nofile] = 65536
default[:nginx]['configure_flags'] = ["--add-module=#{node[:neon][:code_root]}/imageservingplatform/neon_isp"]
default[:nginx][:source][:modules] = %w(
  nginx::http_realip_module
  nginx::http_geoip_module
)

# Force_Default is needed because these parameters are set in the nginx recipe
force_default[:nginx][:realip][:header] = "X-Forwarded-For"
force_default[:nginx][:realip][:addresses] = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
force_default[:nginx][:realip][:real_ip_recursive] = "on"
force_default[:nginx]['worker_processes'] = 1
force_default[:nginx]['worker_connections'] = 12000
force_default[:nginx]['worker_rlimit_nofile'] = 200000
