# This recipe gets the most recent version of the repository

include_recipe "neon::default"

# Create the code directory
directory node[:neon][:code_root] do
  action :create
  owner "neon"
  group "neon"
  mode "1755"
  recursive true
end

# Install the ssh deploy key to get the repository
directory "#{node[:neon][:home]}/.ssh" do
  owner "neon"
  group "neon"
  action :create
  mode "0700"
end
s3_file "#{node[:neon][:home]}/.ssh/neon.pem" do
  source node[:neon][:repo_key]
  owner "neon"
  group "neon"
  action :create
  mode "0600"
end
template "#{node[:neon][:home]}/wrap-ssh4git.sh" do
  owner "neon"
  group "neon"
  source "wrap-ssh4git.sh.erb"
  mode "0755"
  variables({:ssh_key => "#{node[:neon][:home]}/.ssh/neon.pem"})
end

# Get the code repository
git node[:neon][:code_root] do
  repository "git@github.com:neon-lab/neon-codebase.git"
  revision node[:neon][:code_revision]
  enable_submodules true
  action :sync
  user "neon"
  group "neon"
  ssh_wrapper "#{node[:neon][:home]}/wrap-ssh4git.sh"
end
