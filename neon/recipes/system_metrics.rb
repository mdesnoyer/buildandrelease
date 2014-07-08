# System metrics collecter recipe

# List the python dependencies for this server.
pydeps = {
  "tornado" => "3.1.1",
  "PyYAML" => "3.10",
  "boto" => "2.29.1",
  "psutil" => "1.2.1",
}

# Install the python dependencies
pydeps.each do |package, vers|
  python_pip package do
    version vers
    options "--no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
  end
end

# Collect system metrics
service "neon-system-metrics" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
  subscribes :restart, "git[#{node[:neon][:code_root]}]"
end
  
# Write the daemon service wrapper for collecting system metrics
template "/etc/init/neon-system-metrics.conf" do
  source "system_metrics_service.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
                :neon_root_dir => node[:neon][:code_root],
                :user => "neon",
                :group => "neon",
            })
end

# start collecting the system metrics
service "neon-system-metrics" do
  action [:enable, :start]
end
