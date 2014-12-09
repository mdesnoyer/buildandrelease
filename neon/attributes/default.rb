include_attribute "python"
include_attribute "java"

default[:neon][:home] = "/mnt/neon"

# The ssh key to serving machines
default[:neon][:serving_key] = "s3://neon-keys/neon-serving.pem"

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

# set the desired java version
default[:java][:install_flavor] = 'oracle'
default[:java][:jdk_version] = '7'
default[:java][:oracle][:accept_oracle_download_terms] = true

# Aws access keys
default[:aws][:access_key_id] = ENV['AWS_ACCESS_KEY_ID']
default[:aws][:secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY']

# Set desired python settings
default[:python][:virtualenv_version] = "1.11.6"
