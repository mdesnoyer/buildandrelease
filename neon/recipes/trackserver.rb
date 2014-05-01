# This recipe installs the neon click trackserver

# List the python dependencies for this server. We don't install
# all the neon dependencies so that the server can come up more
# quickly
pydeps = {
  "futures" => "2.1.5",
  "tornado" => "3.1.1",
  "shortuuid" => "0.3",
  "PyYAML" => "3.10",
  "boto" => "2.6.0",
  "simplejson" => "2.3.2",
  "nose" => "1.3.1"
}

if node[:opsworks][:activity] == 'setup' do
    # Install the python dependencies
    pydeps.each do |package, vers|
      python_pip package do
        version vers
        options "--no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
      end
    end

    # Install the mail client
    package "mailutils" do
      :install
    end

    # Test the trackserver
    execute "nosetests --exe clickTracker" do
      cwd node[:neon][:code_root]
      user "neon"
    end

    # Write the daemon service wrapper
    template "/etc/init/neon-trackserver.conf" do
      source "trackserver_service.conf.erb"
      owner "root"
      mode "0755"
      variables({
                  :neon_root_dir => node[:neon][:code_root],
                  :config_file => node[:neon][:trackserver][:config],
                  :user => "neon",
                  :group => "neon",
                })
    end

    # Write a script that will send a mail when the service dies
    template "/etc/init/neon-trackserver-email.conf" do
      source "mail-on-restart.conf.erb"
      owner "root"
      mode "0755"
      variables({
                  :service => "neon-trackserver",
                  :host => node[:hostname],
                  :email => node[:neon][:ops_email],
                  :log_file => node[:neon][:trackserver][:log_file]
                })
    end

 end

if node[:opsworks][:activity] == 'config' do
    # Write the configuration file
    template node[:neon][:trackserver][:config] do
      source "trackserver.conf.erb"
      owner "neon"
      mode "0755"
      variables({
                  :port => node[:neon][:trackserver][:port],
                  :flume_port => node[:neon][:trackserver][:flume_port],
                  :backup_dir => node[:neon][:trackserver][:backup_dir],
                  :log_file => node[:neon][:trackserver][:log_file],
                  :carbon_host => node[:neon][:carbon_host],
                  :carbon_port => node[:neon][:carbon_port],
                })
    end

end

if node[:opsworks][:activity] == 'deploy' do
    service "neon-trackserver" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action :start
  end


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off the trackserver
  service "neon-trackserver" do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true, :start => true, :stop => true
    action :stop
  end
end