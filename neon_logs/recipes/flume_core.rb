node.default[:hadoop][:distribution] = 'cdh'
node.default[:hadoop][:distribution_version] = '5'

include_recipe "apt"
include_recipe "java::default"

include_recipe "hadoop::repo"

package "flume-ng" do
  action :install
  version "1.5.0"
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

directory node[:neon_logs][:s3_buffer_dir] do
  owner node[:neon_logs][:flume_user]
  mode "0755"
  action :create
  recursive true
end

include_recipe "neon_logs::flume_core_config"
include_recipe "hadoop"

service node[:neon_logs][:flume_service_name] do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
  action [:enable, :start]
  subscribes :restart, "template[/etc/hadoop/#{node['hadoop']['conf_dir']}/core-site.xml]"
end


if ['shutdown'].include? node[:opsworks][:activity] then
  service node[:neon_logs][:flume_service_name] do
    action :stop
  end
end

cron "monitor_flume_cron" do
  action node[:neon_logs][:monitor_flume] ? :create : :delete
  user node[:neon_logs][:flume_user]
  mailto "ops@neon-lab.com"
  command "#{conf_dir}/monitor_flume.py"
end
