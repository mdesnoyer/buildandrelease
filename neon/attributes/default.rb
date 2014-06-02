# Which revision of the codebase to grab. Can also use tags
default[:neon][:code_revision] = "HEAD"

# The neon codebase root
default[:neon][:home] = "/opt/neon"
default[:neon][:code_root] = "#{node[:neon][:home]}/neon-codebase"

# The ssh key for access the neon repo
default[:neon][:repo_key] = "s3://neon-keys/neon-deploy.pem"

# The python virtualenv
default[:neon][:pyenv] = "#{node[:neon][:code_root]}/.pyenv"

# Parameters for the monitoring server
default[:neon][:carbon_host] = "54.225.235.97"
default[:neon][:carbon_port] = 8090

# Common directories
default[:neon][:config_dir] = "/opt/neon/config"
default[:neon][:log_dir] = "/mnt/neon/logs"

# Notification settings
default[:neon][:ops_email] = "ops@neon-lab.com"

# Parameters for the trackserver
default[:neon][:trackserver][:config] = "#{node[:neon][:config_dir]}/trackserver.conf"
default[:neon][:trackserver][:log_file] = "#{node[:neon][:log_dir]}/trackserver.log"
default[:neon][:trackserver][:port] = 7214 # Port being listened to internally
default[:neon][:trackserver][:external_port] = 80 # External port being listened to
default[:neon][:trackserver][:flume_port] = 6360
default[:neon][:trackserver][:backup_dir] = "/mnt/neon/trackserver/backlog"

# Parameters for the clicklog_collector
default[:neon][:clicklog_collector][:s3_path] = "s3n://neon-tracker-logs-v2/v%{track_vers}/%{tai}/%Y/%m/%d"
default[:neon][:clicklog_collector][:channel_dir] = "/mnt/neon/channels/clicklog"

# Nginx parameters
default[:nginx][:init_style] = "upstart"
default[:nginx][:large_client_header_buffers] = "8 1024000"
default[:nginx][:disable_access_log] = true
default[:nginx][:install_method] = "source"
default[:nginx][:log_dir] = "#{node[:neon][:log_dir]}/nginx"
default[:nginx][:worker_rlimit_nofile] = 65536
default[:nginx][:source][:modules] = %w(
  nginx::http_realip_module
  nginx::http_geoip_module
)
# Force_Default is needed because these parameters are set in the nginx recipe
force_default[:nginx][:realip][:header] = "X-Forwarded-For"
force_default[:nginx][:realip][:addresses] = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
force_default[:nginx][:realip][:real_ip_recursive] = "on"

# ssh key to control Elastic Map Reduce clusters
default[:neon][:emr_key] = "s3://neon-keys/emr-runner.pem"


