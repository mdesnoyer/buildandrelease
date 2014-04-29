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
  "simplejson" => "2.3.2"
}

if node[:opsworks][:activity] == 'setup' do
    # Install the python dependencies
    pydeps.each do |package, vers|
      python_pip package do
        version vers
        options "--no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
      end
    end

    # Write the daemon service wrapper
    template "/etc/init/neon-trackserver.conf" do
      source "trackserver_service.conf.erb"
      owner "root"
      mode "0755"
      variables({
                  :neon_root_dir => node[:neon][:code_root],
                  :config_file => node[:neon][:trackserver][:config]
                })
    end
 end

if node[:opsworks][:activity] == 'config' do
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


if ['undeploy', 'shutdown'].include? node[:opsworks][:activity] then
  # Turn off the trackserver
  service neon-trackserver do
    init_command 
    supports :status => true, :restart => true, :start => true, :stop => true
    action :stop
  end
end
