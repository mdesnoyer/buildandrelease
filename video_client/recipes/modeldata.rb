# Git Annex & setup model data
# TODO: Fix the /root/.gitconfig lock issue & change user to root

directory "/root/.ssh" do  
  user "root"
  group "root"
  mode "0700"
end

s3_file "/root/.ssh/git-annex.pem" do
  source node[:video_client][:gitannex_key]
  owner "root"
  group "root"
  action :create
  mode "0600"
end

apt_package "git-annex" do
    action :install
end

template "/root/.ssh/config" do
  source "gitannex-ssh-config.erb"
  owner "root"
  group "root"
  mode "0600"
  variables({
            :hostname => "#{node[:video_client][:model_data_host]}",
            :key_file => "/root/.ssh/git-annex.pem",
  })
end
 
bash 'root' do
  user "root" 
  cwd "#{node[:neon][:home]}"
  code <<-EOH
  git clone git@#{node[:video_client][:model_data_loc]} model_data
  cd model_data
  git annex sync
  git annex get
  EOH
end
