include_recipe "apt"
include_recipe "java::sun"
include_recipe "hadoop::repo"

package "flume-ng" do
  action :install
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

template "#{conf_dir}/flume-env.sh" do
  source "flume-env.sh.erb"
  owner  node[:neon_logs][:flume_user]
  mode   "0744"
  variables({
      :classpath => node["neon_logs"]["classpath"],
      :java_opts => node["neon_logs"]["java_opts"],
    })
end

service_bin = "#{conf_dir}/#{node[:neon_logs][:flume_service_name]}"

if node[:opsworks][:activity] == 'configure' then
  template service_bin do
    source "flume-ng-agent.erb"
    owner node[:neon_logs][:flume_user]
    mode "0755"
    variables({
                :service_name => node[:neon_logs][:flume_service_name],
                :agent_name => node[:neon_logs][:flume_agent_name],
                :flume_bin => node[:neon_logs][:flume_bin],
                :flume_log_dir => node[:neon_logs][:flume_log_dir],
                :flume_conf_dir => node[:neon_logs][:flume_conf_dir],
                :flume_run_dir => node[:neon_logs][:flume_run_dir],
                :flume_home => node[:neon_logs][:flume_home],
                :flume_user => node[:neon_logs][:flume_user]
              })
  end

  service node[:neon_logs][:flume_service_name] do
    init_command service_bin
    supports :status => true, :restart => true, :start => true, :stop => true
    action :enable
  end
end



if node[:opsworks][:activity] == 'deploy' then
  service node[:neon_logs][:flume_service_name] do
    action :start
  end
elsif node[:opsworks][:activity] == 'undeploy' then
  service node[:neon_logs][:flume_service_name] do
    action :stop
  end
end
