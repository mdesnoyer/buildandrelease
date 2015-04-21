# Git Annex & setup model data

apt_package "git-annex" do
    action :install
end

directory node[:video_client][:model_data_folder] do
  action :create
  owner "neon"
  group "neon"
  mode "1755"
  recursive true
end

# Install the ssh deploy key to get the repository
if node[:video_client][:gitannex_key].start_with?("s3://") then
  # The key is on s3, so go get it
  s3_file "#{node[:neon][:home]}/.ssh/model_data.pem" do
    source node[:video_client][:gitannex_key]
    owner "neon"
    group "neon"
    action :create
    mode "0600"
  end
else
  # The key is in the variable, so write it to a file
  file "#{node[:neon][:home]}/.ssh/model_data.pem" do
    content node[:video_client][:gitannex_key]
    owner "neon"
    group "neon"
    action :create
    mode "0600"
  end
end

template "#{node[:neon][:home]}/.ssh/config" do
  source "gitannex-ssh-config.erb"
  owner "neon"
  group "neon"
  mode "0600"
  variables({
            :hostname => node[:video_client][:model_data_host],
            :key_file => "#{node[:neon][:home]}/.ssh/model_data.pem",
  })
end

bash "get_model_file" do
  user "neon"
  cwd node[:video_client][:model_data_folder]
  code <<-EOH
  git clone #{node[:video_client][:model_data_repo]} .
  git config user.email ops@neon-lab.com
  git config user.name #{node[:opsworks][:instance][:hostname]}
  git annex sync
  git annex get #{node[:video_client][:model_file]}
  EOH
  action :run
end

# Use an md5 of the model file to see if it has changed and trigger a
# service restart.
file "#{node[:neon][:home]}/model_file.md5" do
  content lazy { Digest::MD5.file("#{node[:video_client][:model_data_folder]}/#{node[:video_client][:model_file]}").hexdigest }
  owner "neon"
  group "neon"
  mode "0644"
  action :create
end
