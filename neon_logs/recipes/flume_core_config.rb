
conf_dir = get_config_dir()
log_dir = get_log_dir()
run_dir = get_run_dir()

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

template "#{conf_dir}/flume.conf" do
  source "flume.conf.erb"
  owner  node[:neon_logs][:flume_user]
  mode "0744"
  variables({
              :streams => node[:neon_logs][:flume_streams]
            })
end
