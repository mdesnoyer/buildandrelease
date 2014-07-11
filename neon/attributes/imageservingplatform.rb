# Nginx parameters
#default['nginx']['source']['version'] = '1.4.7'
default[:nginx][:user] = "neon"
default[:nginx][:init_style] = "upstart"
default[:nginx][:large_client_header_buffers] = "8 1024000"
default[:nginx][:disable_access_log] = false 
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

# System configs

force_default[:opsworks_initial_setup][:sysctl]['net.core.somaxconn'] = 10240     
force_default[:opsworks_initial_setup][:sysctl]['net.core.netdev_max_backlog'] = 10240
force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.tcp_max_syn_backlog'] = 2048 # 1024
force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.tcp_fin_timeout'] = 15 
force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.tcp_keepalive_time'] = 100
force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.tcp_max_orphans'] = 131072
force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.tcp_tw_reuse'] = 1   

# Allow a high number of timewait sockets
force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.tcp_max_tw_buckets'] = 2000000

# Wait a maximum of 5 * 2 = 10 seconds in the TIME_WAIT state after a FIN, to handle
# any remaining packets in the network. 
#force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.netfilter.ip_conntrack_tcp_timeout_time_wait'] = 10   

# Determines the wait time between isAlive interval probes (reduce from 75 sec to 15)
#force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.tcp_keepalive_intvl'] = 15   

# increase the ephemeral port range (TODO: figure out the format)
#force_default[:opsworks_initial_setup][:sysctl]['net.ipv4.ip_local_port_range'] = 10000 64000   
