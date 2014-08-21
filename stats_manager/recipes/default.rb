# This recipe installs the neon stats manager

include_recipe "neon::default"
include_recipe "java"

# Create a statsmanager user
user "statsmanager" do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "stats_manager::config"

pydeps = {
  "numpy" => "1.6.1",
  "futures" => "2.1.5",
  "tornado" => "3.1.1",
  "setuptools" => "4.0.1",
  "avro" => "1.7.6",
  "boto" => "2.32.1",
  "impyla" => "0.8.1",
  "simplejson" => "2.3.2",
  "paramiko" => "1.14.0",
  "nose" => "1.3.0",
  "thrift" => "0.9.1",
  "PyYAML" => "3.10",
  "dateutils" => "0.6.6",
}

# Install the python dependencies
pydeps.each do |package, vers|
  python_pip package do
    version vers
    options "--no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
  end
end

# Install the mail client
package "mailutils" do
  :install
end
  
# Install maven
package "maven" do
  :install
end
directory "#{node[:neon][:home]}/.m2" do
  owner "neon"
  group "neon"
  action :create
  mode "0755"
  recursive true
end

# Create the log dir
directory node[:stats_manager][:log_dir] do
  owner "statsmanager"
  group "statsmanager"
  action :create
  mode "0755"
  recursive true
end


aws_keys = {}
if not node[:aws][:access_key_id].nil? then
  aws_keys['AWS_ACCESS_KEY_ID'] = node[:aws][:access_key_id]
  aws_keys['AWS_SECRET_ACCESS_KEY'] = node[:aws][:secret_access_key]
end

node[:deploy].each do |app_name, deploy|
  if app_name != "stats_manager" then
    next
  end

  repo_path = get_repo_path("stats_manager")
  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")

  # Grab the latest repo
  include_recipe "neon::repo"

  # Grab the ssh identity file to talk to the cluster with
  directory "#{node[:neon][:home]}/statsmanager/.ssh" do
    owner "statsmanager"
    group "statsmanager"
    action :create
    mode "0700"
    recursive true
  end
  s3_file "#{node[:neon][:home]}/statsmanager/.ssh/emr.pem" do
    source node[:stats_manager][:emr_key]
    owner "statsmanager"
    group "statsmanager"
    action :create
    mode "0600"
  end

  # Build the job to run
  execute "build stats jar" do
    command "mvn generate-sources package"
    cwd "#{repo_path}/stats/java"
    user "neon"
  end

  # Write the daemon service wrapper
  template "/etc/init/neon-statsmanager.conf" do
    source "statsmanager_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => repo_path,
                :config_file => node[:stats_manager][:config],
                :user => "statsmanager",
                :group => "statsmanager",
                :mr_jar => "#{repo_path}/stats/java/target/neon-stats-1.0-job.jar"
              })
  end
  template "/etc/init/neon-statsmanager-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "neon-statsmanager",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:stats_manager][:log_file]
              })
  end

  service "neon-statsmanager" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{repo_path}]", :delayed
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off the statsmanager
  service "neon-statsmanager" do
    action :stop
  end

  file "/etc/init/neon-statsmanager.conf" do
    action :delete
  end
end
