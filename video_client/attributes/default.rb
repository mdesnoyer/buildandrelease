include_attribute "neon::default"

# Parameters for video_client
default[:video_client][:log_dir] = "#{node[:neon][:log_dir]}/video_client"
default[:video_client][:config] = "#{node[:neon][:config_dir]}/video_client.conf"
default[:video_client][:log_file] = "#{node[:video_client][:log_dir]}/video_client.log"
default[:video_client][:gitannex_key] = "s3://neon-keys/git-annex.pem"
default[:video_client][:model_data_host] = "184.169.132.151"
default[:video_client][:model_data_loc] = "#{node[:video_client][:model_data_host]}:/backup/repos/model_data.git" 
default[:video_client][:model_file] = "model_data/20130924.model"
default[:video_client][:video_db_port] = 6379
default[:video_client][:video_db_fallbackhost] = "redis1"
default[:video_client][:video_db_layer] = "redis"
default[:video_client][:video_server_fallbackhost] = "video-server1"
default[:video_client][:video_server_layer] = "video_server"
default[:video_client][:video_server_port] = 6379

# Specify the repos to user
default[:neon][:repos]["video_client"] = true
default[:neon][:repos]["core"] = true
