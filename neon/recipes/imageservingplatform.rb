# Imageserving platform 

# Configure the flume agent that will listen to the click data and
# will watch the log file.
node.default[:neon_logs][:flume_streams][:isp_nginx_logs] = \
  get_fileagent_config("#{node[:nginx][:log_dir]}/error.log",
                       "isp-nginx")

include_recipe "neon_logs::flume_core"

service "neonisp" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :start => true, :stop => true
  action :nothing
  subscribes :restart, "git[#{node[:neon][:code_root]}]"
end

# Opswork Setup Phase
if node[:opsworks][:activity] == 'setup' then
  # Install nginx
  include_recipe "nginx::default"

  # Install the neon code
  include_recipe "neon::repo"

  # Create a neonisp user
  user "neonisp" do
    action :create
    system true
    shell "/bin/false"
  end

  # Install the mail client
  package "mailutils" do
    :install
  end

  # Make directories 
  file node[:neon][:neonisp][:log_file] do
    user "neonisp"
    group "neon"
    mode "0644"
  end

  # Test the imageservingplatform 
  #execute "nosetests --exe imageservingplatform" do
  #  cwd node[:neon][:code_root]
  #  user "trackserver"
  #end

  # Write a script that will send a mail when the service dies
  #template "/etc/init/neon-isp-email.conf" do
  #  source "mail-on-restart.conf.erb"
  #  owner "root"
  #  group "root"
  #  mode "0644"
  #  variables({
  #              :service => "neon-trackserver",
  #              :host => node[:hostname],
  #              :email => node[:neon][:ops_email],
  #              :log_file => node[:neon][:neonisp][:log_file]
  #            })
  #end

  template "/etc/init/nginx-email.conf" do
    source "mail-on-restart.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "nginx",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => "#{node[:nginx][:log_dir]}/error.log"
              })
  end

end

if ['config', 'setup'].include? node[:opsworks][:activity] then
  node.run_state[:nginx_configure_flags] = node.run_state[:nginx_configure_flags] | ["--add-module=#{node[:neon][:code_root]}/imageservingplatform/neon_isp"]

  # Write the configuration for nginx
  template "#{node[:nginx][:dir]}/conf.d/neonisp.conf" do
    source "neonisp_nginx.conf.erb"
    owner node['nginx']['user']
    group node['nginx']['group']
    mode "0644"
    variables({
                :port => node[:neon][:neonisp][:port],
                :mastermind_validated_filepath => node[:neon][:neonisp][:mastermind_validated_filepath],
                :mastermind_file_url => node[:neon][:neonisp][:mastermind_file_url]
              })
    notifies :reload, 'service[nginx]'
  end
end

# Opsworks DEPLOY stage
if node[:opsworks][:activity] == 'deploy' then
  service "nginx" do
    action [:enable, :start]
  end
end

# Opsworks UNDEPLOY or SHUTDOWN stage
if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off the trackserver
  service "neonisp" do
    action :stop
  end
end
