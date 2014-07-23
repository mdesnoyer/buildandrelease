chef_gem 'aws-sdk'

# Install python
node.default[:python][:version] = '2.7.5'
include_recipe "python"

node.default[:git][:version] = '1.7.9.5'
include_recipe "git"

# Create a neon user
user "neon" do
  action :create
  shell "/bin/bash"
  home node[:neon][:home]
end

# own the home directory 
directory node[:neon][:home] do
  user "neon"
  group "neon"
  mode "1755"
end

# Create the common directories
directory node[:neon][:config_dir] do
  user "neon"
  group "neon"
  mode "1755"
  recursive true
end

directory node[:neon][:log_dir] do
  user "neon"
  group "neon"
  mode "1755"
  recursive true
end
