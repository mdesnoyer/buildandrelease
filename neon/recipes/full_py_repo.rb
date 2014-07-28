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

# Install all the python dependencies
apps.each do |app| do
    code_path = get_repo_path(app)
    execute "py_pre_reqs[#{app}]" do
      command "pip install --no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html -r #{code_path}/pre_requirements.txt"
      action :nothing
      subscribes :run, "git[#{code_path}]"
    end

    execute "py_install_reqs[#{app}]" do
      command "pip install --no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html -r #{code_path}/requirements.txt"
      action :nothing
      subscribes :run, "execute[py_pre_reqs[#{app}]]", :immediately
    end
end

package "python-nose" do
  :install
end
