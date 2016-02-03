# set the flume sources
node.default[:neon_logs][:flume_streams][:cmsapiauth_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "cmsapiauth")

node.default[:neon_logs][:flume_streams][:cmsapiauth_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "cmsapiauth-flume")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

db_host = get_master_cmsdb_ip()
Chef::Log.info("Connecting to db at #{db_host}")

# Write the configuration file for CMS API AUTH 
template node[:cmsapiauth][:config] do
  source "cmsapiauth.conf.erb"
  owner "cmsapi"
  group "cmsapi"
  mode "0644"
  variables({
              :cmsapiauth_port => node[:cmsapiauth][:port],
              :log_file => node[:cmsapiauth][:log_file],
              :access_log_file => node[:cmsapiauth][:access_log_file],
              :db_port => node[:cmsdb][:master_port],
              :db_host => db_host,
              :postgres_db_host => node[:cmsdb][:postgres_host], 
              :postgres_db_port => node[:cmsdb][:postgres_port], 
              :postgres_db_user => node[:cmsdb][:postgres_user], 
              :postgres_db_password => node[:cmsdb][:postgres_password], 
              :postgres_db_name => node[:cmsdb][:postgres_db_name],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end

cmsapiauth_exists = File.exists?("/etc/init/cmsapiauth.conf")

if cmsapiauth_exists then
  # Specify the service for chef so that they can be restarted.
  service "cmsapiauth" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action :nothing
  end

  service "nginx" do
    action :nothing
  end
end

include_recipe "neon-nginx::commons_dir"

# Write the configuration for nginx
template "#{node[:nginx][:dir]}/conf.d/cmsapiauth.conf" do
  source "cmsapiauth_nginx.conf.erb"
  owner node['nginx']['user']
  group node['nginx']['group']
  mode "0644"
  variables({
              :service_port => node[:cmsapiauth][:port], 
              :frontend_port => 80 
            })
  if cmsapiauth_exists
    notifies :reload, 'service[nginx]', :delayed
  end
end
