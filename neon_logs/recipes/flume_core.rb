node.default[:hadoop][:distribution] = 'cdh'
node.default[:hadoop][:distribution_version] = '5'

include_recipe "apt"
include_recipe "java::default"

if node[:opsworks][:activity] == 'setup' then
  include_recipe "hadoop::repo"

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
run_dir = get_run_dir()

directory conf_dir do
  owner node[:neon_logs][:flume_user]
  mode "0755"
  action :create
  recursive true
end

directory log_dir do
  owner node[:neon_logs][:flume_user]
  mode "0755"
  action :create
  recursive true
end

directory run_dir do
  owner node[:neon_logs][:flume_user]
  mode "0755"
  action :create
  recursive true
end


service_bin = get_service_bin()

service node[:neon_logs][:flume_service_name] do
  init_command service_bin
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
end

if node[:opsworks][:activity] == 'setup' then
  include_recipe "hadoop"

  template "#{conf_dir}/flume-env.sh" do
    source "flume-env.sh.erb"
    owner  node[:neon_logs][:flume_user]
    mode   "0744"
    variables({
                :classpath => node["neon_logs"]["classpath"],
                :java_opts => node["neon_logs"]["java_opts"],
              })
  end

  # Create an empty config file so that the flume service can
  # start. When configure happens, it will be rewritten and
  # automatically picked up by flume.
  file "#{conf_dir}/flume.conf" do
    owner  node[:neon_logs][:flume_user]
    mode "0600"
    action :create_if_missing
  end

  template service_bin do
    source "flume-ng-agent.erb"
    owner "root"
    mode "0755"
    variables({
                :service_name => node[:neon_logs][:flume_service_name],
                :agent_name => node[:neon_logs][:flume_agent_name],
                :flume_bin => node[:neon_logs][:flume_bin],
                :flume_log_dir => log_dir,
                :flume_conf_dir => conf_dir,
                :flume_run_dir => run_dir,
                :flume_home => node[:neon_logs][:flume_home],
                :flume_user => node[:neon_logs][:flume_user]
              })
  end

  service node[:neon_logs][:flume_service_name] do
    init_command service_bin
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
  end
end

if node[:opsworks][:activity] == 'configure' then
  template "#{conf_dir}/flume.conf" do
    source "flume.conf.erb"
    owner  node[:neon_logs][:flume_user]
    mode "0744"
    variables({
                :agent => node[:neon_logs][:flume_agent_name],
                :streams => node[:neon_logs][:flume_streams]
              })
    notifies :start, "service[#{node[:neon_logs][:flume_service_name]}]"
  end
end

if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  service node[:neon_logs][:flume_service_name] do
    init_command service_bin
    supports :status => true, :restart => true, :start => true, :stop => true
    action :stop
  end
end
