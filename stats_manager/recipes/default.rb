# This recipe installs the neon stats manager

include_recipe "neon::default"

# Configure the flume agent that will listen to the logs from the
# stats manager job
node.default[:neon_logs][:flume_streams][:trackserver_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "stats_manager")

include_recipe "neon_logs::flume_core"

include_recipe "java"

pydeps = {
  "futures" => "2.1.5",
  "tornado" => "3.1.1",
  "setuptools" => "4.0.1",
  "avro" => "1.7.6",
  "boto" => "2.29.1",
  "impyla" => "0.8.1",
  "simplejson" => "2.3.2",
  "paramiko" => "1.14.0",
  "nose" => "1.3.0",
  "thrift" => "0.9.1",
  "PyYAML" => "3.10"
}

# Install the python dependencies
pydeps.each do |package, vers|
  python_pip package do
    version vers
    options "--no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
  end
end

# Create a statsmanager user
user "statsmanager" do
  action :create
  system true
  shell "/bin/false"
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
directory "#{node[:neon][:log_dir]}/stats_manager" do
  owner "statsmanager"
  group "statsmanager"
  action :create
  mode "0755"
  recursive true
end


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

repo_path = get_repo_path("Stats Manager")

aws_keys = {}
if not node[:aws][:access_key_id].nil? then
  aws_keys['AWS_ACCESS_KEY_ID'] = node[:aws][:access_key_id]
  aws_keys['AWS_SECRET_ACCESS_KEY'] = node[:aws][:secret_access_key]
end

if ::File.exists?("#{repo_path}/stats/batch_processor.py") then
  execute "get cluster host key" do
    command "#{repo_path}/stats/batch_processor.py --master_host_key_file #{node[:neon][:home]}/statsmanager/.ssh/cluster_known_hosts --get_master_host_key 1"
    user "statsmanager"
    environment aws_keys
  end
end

if node[:opsworks][:activity] == 'deploy' then
  # Grab the latest repo
  include_recipe "neon::repo"

  # Build the job to run
  execute "build stats jar" do
    command "mvn generate-sources package"
    cwd "#{repo_path}/stats/java"
    user "neon"
  end

  # Turn on the cron job
  cron "stats_manager" do
    action :create
    user "statsmanager"
    hour "1-23/3"
    minute "10"
    mailto "ops@neon-lab.com"
    command "#{repo_path}/stats/batch_processor.py --mr_jar #{repo_path}/stats/java/target/neon-stats-1.0-job.jar --utils.monitor.carbon_server #{node[:neon][:carbon_host]} --utils.monitor.carbon_port #{node[:neon][:carbon_port]} --utils.logs.file #{node[:neon][:log_dir]}/stats_manager/stdout.log --utils.logs.do_stderr 0 --master_host_key_file #{node[:neon][:home]}/statsmanager/.ssh/cluster_known_hosts --utils.logs.loggly_tag statsmanager --utils.logs.flume_url http://localhost:#{node[:neon_logs][:json_http_source_port]}" 
    environment aws_keys
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off the cron job
  cron "stats_manager" do
    action :delete
  end
end
