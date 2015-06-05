# System metrics collecter recipe
node.default[:neon][:repos][:core] = true

# Install the neon code
include_recipe "neon::repo"

# List the python dependencies needed for this script.
pydeps = {
  "tornado" => "4.0.2",
  "simplejson" => "2.3.2",
  "PyYAML" => "3.10",
  "boto" => "2.3.2",
  "psutil" => "1.2.1",
  "winpdb" => "1.4.8"
}

# Install the python dependencies
pydeps.each do |package, vers|
  python_pip package do
    version vers
    options "--no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
  end
end

# Collect system metrics
repo_path = get_repo_path("core")
service "neon-system-metrics" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
  subscribes :restart, "git[#{repo_path}]"
end
  
# Write the daemon service wrapper for collecting system metrics
template "/etc/init/neon-system-metrics.conf" do
  source "system_metrics_service.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :neon_root_dir => repo_path,
              :user => "neon",
              :group => "neon",
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port]
            })
end

# start collecting the system metrics
service "neon-system-metrics" do
  action [:enable, :start]
end
