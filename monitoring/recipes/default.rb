# This recipe installs the neon monitoring process

include_recipe "neon::default"

# Setup collecting system metrics
include_recipe "neon::system_metrics"

# Create a monitoring user
user "monitoring" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "monitoring::config"

# Install the python dependencies

pydeps = {
  "futures" => "2.1.5",
  "tornado" => "4.2.1",
  "shortuuid" => "0.3",
  "PyYAML" => "3.10",
  "simplejson" => "2.3.2",
  "nose" => "1.3.0",
  "pyfakefs" => "2.4",
  "mock" => "1.0.1",
  "httpagentparser" => "1.6.0",
  "psutil" => "1.2.1",
  "winpdb" => "1.4.8", 
  "python-dateutil" => "2.4.2" 
}

pydeps.each do |package, vers|
  python_pip package do
    version vers
    options "--no-index --find-links https://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
  end
end

package "python-nose" do
  :install
end

# Make directories 
directory node[:monitoring][:log_dir] do
  user "neon"
  group "neon"
  mode "0755"
end

file node[:monitoring][:log_file] do
  user "neon"
  group "neon"
  mode "0644"
end

node[:deploy].each do |app_name, deploy|
  if app_name != "monitoring" then
    next
  end

  repo_path = get_repo_path(app_name)
  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")
  
  # Install the neon code
  include_recipe "neon::repo"

  # Test the trackserver
  execute "nosetests --exe cmsdb monitoring utils" do
    cwd "#{repo_path}"
    user "neon"
    action :run
    notifies :restart, "service[benchmark_videopipeline]", :delayed
  end

  # Write the daemon service wrapper
  template "/etc/init/benchmark_videopipeline.conf" do
    source "monitoring_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{repo_path}",
                :config_file => node[:monitoring][:config],
                :user => "neon",
                :group => "neon",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/monitoring-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "benchmark_videopipeline",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:monitoring][:log_file]
              })
  end

  service "benchmark_videopipeline" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{repo_path}]", :delayed
  end
end

if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off monitoring
  service "monitoring" do
    action :stop
  end
end
