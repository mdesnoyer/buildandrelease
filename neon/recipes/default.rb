# Install python
node.default[:python][:version] = '2.7.5'
include_recipe "python"

# Create a neon user
user "neon" do
  action :create
  shell "/bin/bash"
  home node[:neon][:home]
end

