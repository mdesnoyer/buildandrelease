include_attribute "neon::default"

# Parameters for video_client
default[:video_client][:log_dir] = "#{node[:neon][:log_dir]}/video_client"
default[:video_client][:config] = "#{node[:neon][:config_dir]}/video_client.conf"
default[:video_client][:log_file] = "#{node[:video_client][:log_dir]}/video_client.log"
default[:video_client][:gitannex_pkg_link] = "https://neon-dependencies.s3.amazonaws.com/git-annex_3.20120406_amd64.deb"
default[:video_client][:gitannex_key] = "s3://neon-test/git-annex.pem"
default[:video_client][:model_data_host] = "184.169.132.151"
default[:video_client][:model_data_loc] = "#{node[:video_client][:model_data_host]}:/backup/repos/model_data.git" 


# Specify the repos to user
default[:neon][:repos]["video_client"] = true
default[:neon][:repos]["core"] = true
