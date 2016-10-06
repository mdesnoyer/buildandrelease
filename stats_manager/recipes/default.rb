# This recipe installs the neon stats manager

include_recipe "neon::default"
include_recipe "java"

# Create a statsmanager user
user node[:stats_manager][:user] do
  action :create
  system true
  shell "/bin/false"
end

include_recipe "stats_manager::config"

# Give statsmanager access to airflow scheduler service
execute "sudoers for statsmanager" do
  command "echo 'statsmanager ALL=NOPASSWD: /usr/sbin/service airflow-scheduler *' >> /etc/sudoers"
  not_if "grep -F 'statsmanager ALL=NOPASSWD: /usr/sbin/service airflow-scheduler *' /etc/sudoers"
  Chef::Log.info("Modifying sudoers to add statsmanager access to airflow service")
end

pydeps = {
  "numpy" => "1.6.1",
  "futures" => "2.1.5",
  "tornado" => "4.2.1",
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
  "winpdb" => "1.4.8",
  "pyhs2" => "0.6.0",
  "happybase" => "0.9",
  "hdfs" => "2.0.6",
  "ConcurrentLogHandler" => "0.9.1"
}

# Install the python dependencies
pydeps.each do |package, vers|
  python_pip package do
    version vers
    options "--no-index --find-links https://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
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
  owner node[:stats_manager][:user]
  group node[:stats_manager][:group]
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
    owner node[:stats_manager][:user]
    group node[:stats_manager][:group]
    action :create
    mode "0700"
    recursive true
  end
  s3_file "#{node[:neon][:home]}/statsmanager/.ssh/emr.pem" do
    bucket node[:stats_manager][:emr_key_bucket] 
    remote_path node[:stats_manager][:emr_key_path]
    owner node[:stats_manager][:user]
    group node[:stats_manager][:group]
    action :create
    mode "0600"
  end

  # Build the job to run
  execute "build stats jar" do
    command "mvn generate-sources package"
    cwd "#{repo_path}/stats/java"
    user "neon"
  end

  # Setup Airflow
  include_recipe "airflow"

  # Write the daemon service wrapper
  template "/etc/init/cluster_manager.conf" do
    source "cluster_manager_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => repo_path,
                :config_file => node[:stats_manager][:config],
                :user => node[:stats_manager][:user],
                :group => node[:stats_manager][:group],
                :airflow_home => node[:airflow][:home],
                :log_file => node[:stats_manager][:cluster_log_file]
              })
  end
  template "/etc/init/cluster_manager-email.conf" do
    source "mail-on-restart.conf.erb"
    cookbook "neon"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "cluster_manager",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:stats_manager][:log_file]
              })
  end

  service "cluster_manager" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{repo_path}]", :delayed
  end
end

if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off the statsmanager
  service "cluster_manager" do
    action :stop
  end

  file "/etc/init/cluster_manager.conf" do
    action :delete
  end
end
