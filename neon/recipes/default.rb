chef_gem 'aws-sdk'

include_recipe "neon::filesystem"

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
  mode "1777"
  recursive true
end

# grab most recent version of libmysqlclient
package "libmysqlclient18" do 
  :install
end

# Install the mail client. 
package "mailutils" do
  :install
  options "--fix-missing"
end

# Install sasl
package "libsasl2-dev" do
  :install
end

# grab the postgresql repo 
apt_repository 'apt.postgresql.org' do
  uri 'http://apt.postgresql.org/pub/repos/apt'
  distribution "precise-pgdg"
  components ['main', '9.4']
  key 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  action :add
end
