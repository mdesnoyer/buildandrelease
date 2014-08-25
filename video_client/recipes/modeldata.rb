# Git Annex & setup model data
# Git annex is pre-installed in the image

directory "#{node[:neon][:home]}/.ssh" do  
  user "neon"
  group "neon"
  mode "0700"
end

s3_file "#{node[:neon][:home]}/.ssh/git-annex.pem" do
  source node[:video_client][:gitannex_key]
  owner "neon"
  group "neon"
  action :create
  mode "0600"
end

#remote_file "/tmp/git-annex.deb" do
#  source "#{node[:video_client][:gitannex_pkg_link]}"
#  mode 0644
#end

#dpkg_package "git-annex" do
#  source "/tmp/git-annex.deb"
#  action :install
#end

template "#{node[:neon][:home]}/.ssh/config" do
  source "gitannex-ssh-config.erb"
  owner "neon"
  group "neon"
  mode "0600"
  variables({
            :hostname => "#{node[:video_client][:model_data_host]}",
            :key_file => "#{node[:neon][:home]}/.ssh/git-annex.pem",
  })
end
 
repo_path = get_repo_path("video_client")
bash 'neon' do
  user "neon" 
  cwd "#{repo_path}"
  code <<-EOH
  git clone git@#{node[:video_client][:model_data_loc]} model_data
  cd model_data
  git config --global user.email "neon@neon-lab.com"
  git config --global user.name "neon
  git annex sync
  git annex get
  EOH
end
