# This recipe installs the neon click trackserver

include_recipe "neon::default"

# Configure the flume agent that will listen to the click data and
# will watch the log file.
node.default[:neon_logs][:flume_streams][:click_data] = \
  get_thriftagent_config(node[:trackserver][:flume_port],
                         "tracklog",
                         "tracklog_collector",
                         node[:neon_logs][:collector_port])

node.default[:neon_logs][:flume_streams][:trackserver_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "trackserver")

node.default[:neon_logs][:flume_streams][:trackserver_flume_logs] = \
  get_fileagent_config("#{get_log_dir()}/flume.log",
                       "trackserver-flume")

node.default[:neon_logs][:flume_streams][:trackserver_nginx_logs] = \
  get_fileagent_config("#{node[:nginx][:log_dir]}/error.log",
                       "trackserver-nginx")

include_recipe "neon_logs::flume_core"

# List the python dependencies for this server. We don't install
# all the neon dependencies so that the server can come up more
# quickly
pydeps = {
  "futures" => "2.1.5",
  "tornado" => "3.1.1",
  "shortuuid" => "0.3",
  "PyYAML" => "3.10",
  "boto" => "2.29.1",
  "simplejson" => "2.3.2",
  "nose" => "1.3.0",
  "pyfakefs" => "2.4",
  "mock" => "1.0.1",
  "httpagentparser" => "1.6.0",
  "avro" => "1.7.6",
  "thrift" => "0.9.1",
  "psutil" => "1.2.1",
}

if node[:opsworks][:activity] == 'setup' then
  # Install nginx
  include_recipe "nginx::default"

  # Setup collecting system metrics
  include_recipe "neon::system_metrics"

  # Create a trackserver user
  user "trackserver" do
    action :create
    system true
    shell "/bin/false"
  end

  # Install the python dependencies
  pydeps.each do |package, vers|
    python_pip package do
      version vers
      options "--no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
    end
  end

  # Setup collecting system metrics
  include_recipe "neon::system_metrics"

  # Install the mail client
  package "mailutils" do
    :install
  end

  # Make directories 
  file node[:trackserver][:log_file] do
    user "trackserver"
    group "neon"
    mode "0644"
  end
  directory node[:trackserver][:backup_dir] do
    user "trackserver"
    group "neon"
    mode "1775"
    recursive true
  end

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
  # Write the configuration file for the trackserver
  template node[:trackserver][:config] do
    source "trackserver.conf.erb"
    owner "trackserver"
    group "trackserver"
    mode "0644"
    variables({
                :port => node[:trackserver][:port],
                :flume_port => node[:trackserver][:flume_port],
                :backup_dir => node[:trackserver][:backup_dir],
                :log_file => node[:trackserver][:log_file],
                :carbon_host => node[:neon][:carbon_host],
                :carbon_port => node[:neon][:carbon_port],
                :flume_log_port => node[:neon_logs][:json_http_source_port],
              })
  end

  # Write the configuration for nginx
  template "#{node[:nginx][:dir]}/conf.d/trackserver.conf" do
    source "trackserver_nginx.conf.erb"
    owner node['nginx']['user']
    group node['nginx']['group']
    mode "0644"
    variables({
                :service_port => node[:trackserver][:port],
                :frontend_port => node[:trackserver][:external_port]
              })
    notifies :reload, 'service[nginx]'
  end
end

if node[:opsworks][:activity] == 'deploy' then
  # Install the neon code
  include_recipe "neon::repo"

  # Test the trackserver
  execute "nosetests --exe clickTracker" do
    cwd "#{node[:neon][:code_root]}/trackserver"
    user "trackserver"
    action :nothing
    subscribes :run, "git[#{node[:neon][:code_root]}/trackserver]", :immediately
  end

  # Write the daemon service wrapper
  template "/etc/init/neon-trackserver.conf" do
    source "trackserver_service.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :neon_root_dir => "#{node[:neon][:code_root]}/trackserver",
                :config_file => node[:trackserver][:config],
                :user => "trackserver",
                :group => "trackserver",
              })
  end

  # Write a script that will send a mail when the service dies
  template "/etc/init/neon-trackserver-email.conf" do
    source "mail-on-restart.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables({
                :service => "neon-trackserver",
                :host => node[:hostname],
                :email => node[:neon][:ops_email],
                :log_file => node[:trackserver][:log_file]
              })
  end

  service "neon-trackserver" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action [:enable, :start]
    subscribes :restart, "git[#{node[:neon][:code_root]}/trackserver]"
    subscribes :restart, "template[#{node[:trackserver][:config]}]"
  end
end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off the trackserver
  service "neon-trackserver" do
    action :stop
  end
end
