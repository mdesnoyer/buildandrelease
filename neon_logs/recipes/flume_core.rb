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

directory node[:neon_logs][:s3_buffer_dir] do
  owner node[:neon_logs][:flume_user]
  mode "0755"
  action :create
  recursive true
end

service node[:neon_logs][:flume_service_name] do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
  subscribes :restart, "template[/etc/hadoop/#{node['hadoop']['conf_dir']}/core-site.xml]"
end

if ['configure', 'setup'].include? node[:opsworks][:activity] then
  if node[:neon_logs][:monitor_flume] then
    node.default[:neon_logs][:java_opts] = \
    [
     "-Dflume.monitoring.type=http",
     "-Dflume.monitoring.port=#{node[:neon_logs][:flume_monitoring_port]}"
    ]
  end

  template "#{conf_dir}/flume-env.sh" do
    source "flume-env.sh.erb"
    owner  node[:neon_logs][:flume_user]
    mode   "0744"
    variables({
                :classpath => node["neon_logs"]["classpath"],
                :java_opts => node["neon_logs"]["java_opts"],
              })
    notifies :restart, "service[#{node[:neon_logs][:flume_service_name]}]"
  end

  template "#{conf_dir}/log4j.properties" do
    source "flume_log4j.conf.erb"
    owner  node[:neon_logs][:flume_user]
    mode   "0644"
    variables({ :log_dir => log_dir,
              })
    notifies :restart, "service[#{node[:neon_logs][:flume_service_name]}]"
  end

  template "#{conf_dir}/jets3t.properties" do
    source "jets3t.properties.erb"
    owner  node[:neon_logs][:flume_user]
    mode   "0644"
    variables({:max_s3_upload_speed => node[:neon_logs][:max_s3_upload_speed],
              })
    notifies :restart, "service[#{node[:neon_logs][:flume_service_name]}]"
  end

  # Write a script that will send a mail when flume dies
  template "/etc/init/flume-email.conf" do
    source "mail-on-restart.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => node[:neon_logs][:flume_service_name],
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => "#{log_dir}/flume.log"
              })
  end

  template "/etc/init/#{node[:neon_logs][:flume_service_name]}.conf" do
    source "flume-ng-service.conf.erb"
    owner "root"
    mode "0755"
    variables({
                :flume_bin => node[:neon_logs][:flume_bin],
                :flume_conf_dir => conf_dir,
                :flume_run_dir => run_dir,
                :flume_user => node[:neon_logs][:flume_user],
                :flume_group => node[:neon_logs][:flume_user]
              })
    notifies :restart, "service[#{node[:neon_logs][:flume_service_name]}]"
  end

  if node[:neon_logs][:monitor_flume] then
    template "#{conf_dir}/monitor_flume.py" do
      source "monitor_flume.py.erb"
      owner node[:neon_logs][:flume_user]
      mode "0755"
      variables({
                  :flume_monitoring_port => node[:neon_logs][:flume_monitoring_port],
                  :carbon_host => node[:neon_logs][:carbon_host],
                  :carbon_port => node[:neon_logs][:carbon_port]
                })
    end
  end
end

if node[:opsworks][:activity] == 'setup' then
  include_recipe "hadoop"

  # Create an empty config file so that the flume service can
  # start. When configure happens, it will be rewritten and
  # automatically picked up by flume.
  file "#{conf_dir}/flume.conf" do
    owner  node[:neon_logs][:flume_user]
    mode "0600"
    action :create_if_missing
  end

  service node[:neon_logs][:flume_service_name] do
    action [:enable, :start]
  end
end

if node[:opsworks][:activity] == 'configure' then
  template "#{conf_dir}/flume.conf" do
    source "flume.conf.erb"
    owner  node[:neon_logs][:flume_user]
    mode "0744"
    variables({
                :streams => node[:neon_logs][:flume_streams]
              })
    notifies :start, "service[#{node[:neon_logs][:flume_service_name]}]"
  end
end

if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  service node[:neon_logs][:flume_service_name] do
    action :stop
  end
end

cron monitor_flume_cron do
  action default[:neon_logs][:monitor_flume] ? :create : :delete
  user node[:neon_logs][:flume_user]
  mailto "ops@neon-lab.com"
  command "#{conf_dir}/monitor_flume.py"
end
