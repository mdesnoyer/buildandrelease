# Installs the full python repo and all of the dependencies in the
# requirements.txt file.

# Install the repo
include_recipe "neon::repo"

apps = [nil]
if node[:opsworks][:activity] == 'deploy' then
  node[:deploy].each do |app, data|
    apps << app
  end
end

# Install packages that are needed
package_deps = [
  "libfreetype6-dev",
  "libatlas-base-dev"
]
package_deps.each do |pkg|
  package pkg do
    action :install
  end
end

# Install all the python dependencies
apps.each do |app|
  code_path = get_repo_path(app)
  execute "py_pre_reqs[#{app}]" do
    command "pip install --no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html -r #{code_path}/pre_requirements.txt"
    action :run
  end

  execute "py_install_reqs[#{app}]" do
    command "pip install --no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html -r #{code_path}/requirements.txt"
    action :run
  end
end

package "python-nose" do
  :install
end
