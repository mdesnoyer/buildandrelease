include_attribute "python"
include_attribute "java"

default[:neon][:home] = "/opt/neon"

# The ssh key to serving machines
default[:neon][:serving_key_bucket] = "neon-keys"
default[:neon][:serving_key_path] = "neon-serving.pem"

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

# Address to get the ip ranges inside amazon from
default[:aws][:ip_ranges_url] = "https://ip-ranges.amazonaws.com/ip-ranges.json"

# Model
default[:neon][:model_file] = "local_search_input_20160523"
default[:neon][:model_data_folder] = "#{node[:neon][:home]}/model_data/repo"
default[:neon][:model_autoscale_groups] = "AquilaOnDemandTest"
default[:neon][:request_concurrency] = 22

# Parameters needed for cmsapi
default[:neon][:auth_host] = "auth.neon-lab.com"
default[:neon][:api_host] = "services.neon-lab.com"
default[:neon][:cmsapi_user] = "admin_neon_ingester"
default[:neon][:cmsapi_pass] = nil
