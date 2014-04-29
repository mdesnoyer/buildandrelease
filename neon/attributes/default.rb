# Which branch of the codebase to grab
default[:neon][:code_branch] = "master"
default[:neon][:code_revision] = "HEAD"

# The neon codebase root
default[:neon][:code_root] = "/opt/neon/neon-codebase"

# The python virtualenv
default[:neon][:pyenv] = "#{node[:neon][:code_root]}/.pyenv"

# Parameters for the monitoring server
default[:neon][:carbon_host] = "54.225.235.97"
default[:neon][:carbon_port] = 8090

# Common directories
default[:neon][:config_dir] = "/opt/neon/config"
default[:neon][:log_dir] = "/mnt/neon/logs"

# Notification settings
default[:neon][:ops_email] = "ops@neon-labs.com"

# Parameters for the trackserver
default[:neon][:trackserver][:config] = "#{node[:neon][:config_dir]}/trackserver.conf"
default[:neon][:trackserver][:log_file] = "#{node[:neon][:log_dir]}/trackserver.log"
default[:neon][:trackserver][:port] = 7214
default[:neon][:trackserver][:flume_port] = 6367
default[:neon][:trackserver][:backup_dir] = "/mnt/neon/trackserver/backlog"
