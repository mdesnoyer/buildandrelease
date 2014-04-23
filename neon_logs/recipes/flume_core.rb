include_recipe "apt"
include_recipe "java::default"

if node[:opsworks][:activity] == 'setup' then
  apt_repository "cloudera-cdh5" do
    uri "http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh"
    key "http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh/archive.key"
    distribution "precise-cdh5"
    components [ "contrib" ]
    arch "amd64"
    action :add
  end


  package "flume-ng" do
    action :install
  end
end

user node[:neon_logs][:flume_user] do
  action :create
  system true
  shell "/bin/false"
end

# Set the variables for the paths based on the service name being used
conf_dir = get_config_dir()
log_dir = get_log_dir()

directory conf_dir do
  owner node[:neon_logs][:flume_user]
  mode "0755"
  action :create
end

directory log_dir do
  owner node[:neon_logs][:flume_user]
  mode "0755"
  action :create
end


service_bin = "/etc/init.d/#{node[:neon_logs][:flume_service_name]}"

service node[:neon_logs][:flume_service_name] do
  init_command service_bin
  supports :status => true, :restart => true, :start => true, :stop => true
  action :enable
end

if node[:opsworks][:activity] == 'setup' then
  template "#{conf_dir}/flume-env.sh" do
    source "flume-env.sh.erb"
    owner  node[:neon_logs][:flume_user]
    mode   "0744"
    variables({
                :classpath => node["neon_logs"]["classpath"],
                :java_opts => node["neon_logs"]["java_opts"],
              })
  end

  template service_bin do
    source "flume-ng-agent.erb"
    owner node[:neon_logs][:flume_user]
    mode "0755"
    variables({
                :service_name => node[:neon_logs][:flume_service_name],
                :agent_name => node[:neon_logs][:flume_agent_name],
                :flume_bin => node[:neon_logs][:flume_bin],
                :flume_log_dir => log_dir,
                :flume_conf_dir => conf_dir,
                :flume_run_dir => node[:neon_logs][:flume_run_dir],
                :flume_home => node[:neon_logs][:flume_home],
                :flume_user => node[:neon_logs][:flume_user]
              })
    notifies :reload, "service[#{node[:neon_logs][:flume_service_name]}]"
  end
end



if node[:opsworks][:activity] == 'deploy' then
  service node[:neon_logs][:flume_service_name] do
    init_command service_bin
    supports :status => true, :restart => true, :start => true, :stop => true
    action :start
  end
elsif node[:opsworks][:activity] == 'undeploy' then
  service node[:neon_logs][:flume_service_name] do
    init_command service_bin
    supports :status => true, :restart => true, :start => true, :stop => true
    action :stop
  end
end
