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

# Get the code repository
git node[:neon][:code_root] do
  repository "git@github.com:neon-lab/neon-codebase.git"
  checkout_branch node[:neon][:code_branch]
  revision node[:neon][:code_revision]
  enable_submodules true
  action :sync
  user "neon"
  group "neon"
done
