# Install Git Annex & setup model data

directory "/home/video_client/.ssh" do  
  user "video_client"
  group "neon"
  mode "0700"
end

s3_file "/home/video_client/.ssh/git-annex.pem" do
  source node[:video_client][:gitannex_key]
  owner "video_client"
  group "neon"
  action :create
  mode "0600"
end

remote_file "/tmp/git-annex.deb" do
  source "#{node[:video_client][:gitannex_pkg_link]}"
  mode 0644
end

dpkg_package "git-annex" do
  source "/tmp/git-annex.deb"
  action :install
end

template "/home/video_client/.ssh/config" do
  source "gitannex-ssh-config.erb"
  owner "video_client"
  group "neon"
  mode "0600"
  variables({
            :hostname => "#{node[:video_client][:model_data_host]}",
            :key_file => "/home/video_client/.ssh/git-annex.pem",
  })
end
 
repo_path = get_repo_path("video_client")
bash 'model_data' do
  user "video_client" 
  cwd "#{repo_path}"
  code <<-EOH
  git clone git@#{node[:video_client][:model_data_loc]} model_data
  git annex sync
  git annex get
  EOH
end

