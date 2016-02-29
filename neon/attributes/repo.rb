include_attribute "neon::default"

# The neon codebase root
default[:neon][:code_root] = "#{node[:neon][:home]}/neon-codebase"

# Specifying the repos to install is done by adding them to this hash
# with the key being the application name and the value being true if
# it should be installed.
#
# For example, to have the repo for the track server be installed set:
# default[:neon][:repos]["Track Server"] = true
#
# The repo will be installed if there is a node[:deploy] entry for
# that app name.
#
# Note that the special app name "core" will install a base repo not
# associated with a given deploy app.
default[:neon][:repos] = {}

# Default parameters for the repo if they are not specified in the
# node[:deploy] structure.
default[:neon][:repo_key] = "s3://neon-keys/neon-deploy.pem"
default[:neon][:repo_key_bucket] = "neon-keys"
default[:neon][:repo_key_path] = "neon-deploy.pem"
default[:neon][:code_revision] = "HEAD" # Can also use tags or branches
default[:neon][:repo_url] = "git@github.com:neon-lab/neon-codebase.git"
