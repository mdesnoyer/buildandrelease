include_attribute "neon::default"
include_attribute "cmsdb::default"

# Parameters for video_client
default[:video_client][:log_dir] = "#{node[:neon][:log_dir]}/video_client"
default[:video_client][:config] = "#{node[:neon][:config_dir]}/video_client.conf"
default[:video_client][:log_file] = "#{node[:video_client][:log_dir]}/video_client.log"
default[:video_client][:gitannex_key] = "s3://neon-keys/git-annex.pem"
default[:video_client][:model_data_host] = "184.169.132.151"
default[:video_client][:model_data_repo] = "git@#{node[:video_client][:model_data_host]}:/backup/repos/model_data.git"
default[:video_client][:model_data_repo_rev] = "master"
default[:video_client][:model_file] = "20130924_textdiff.model"
default[:video_client][:model_data_folder] = "#{node[:neon][:home]}/model_data/repo"
default[:video_client][:model_files] = [node[:video_client][:model_file], node[:video_client][:model_data_folder] + "/svm_pca", node[:video_client][:model_data_folder] + "/pca", default[:video_client][:model_data_folder] + "/haar_cascades"]
default[:video_client][:max_videos_per_proc] = 10
default[:video_client][:dequeue_period] = 10.0
default[:video_client][:notification_api_key] = "icAxBCbwo--owZaFED8hWA"
default[:video_client][:server_auth] = "secret_token"
default[:video_client][:extra_workers] = 0
default[:video_client][:video_temp_dir] = "/mnt/tmp1"
default[:video_client][:video_queue_prefix] = "videojobs_priority_"
default[:video_client][:cmsapi_user] = "admin_neon_ingester"
default[:video_client][:cmsapi_pass] = nil

# Specify the repos to user
default[:neon][:repos]["video_client"] = true
default[:neon][:repos]["core"] = true
