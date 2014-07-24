# Configure the flume agent that will watch the log file.
node.default[:neon_logs][:flume_streams][:isp_nginx_logs] = \
  get_fileagent_config("#{node[:nginx][:log_dir]}/error.log",
                       "isp-nginx")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Write the service so that it can be reloaded
service "nginx" do
  action :nothing
end

include_recipe "neon-nginx::commons_dir"

# Write the imageservingplatform configuration for nginx
template "#{node[:nginx][:dir]}/conf.d/neonisp.conf" do
  source "neonisp_nginx.conf.erb"
  owner node['nginx']['user']
  group node['nginx']['group']
  mode "0644"
  variables({
              :port => node[:neonisp][:port],
              :mastermind_validated_filepath => node[:neonisp][:mastermind_validated_filepath],
              :mastermind_file_url => node[:neonisp][:mastermind_file_url],
              :client_expires => node[:neonisp][:client_api_expiry]
            })
  notifies :reload, 'service[nginx]', :delayed
end
