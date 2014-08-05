chef_gem 'aws-sdk'

include_recipe "apt"

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

# Install the mail client. 
apt_preference 'libmysqlclient18' do
  pin 'version 5.5.38-0'
  pin_priority '700'
end
package "mailutils" do
  :install
  options "--fix-missing"
end
