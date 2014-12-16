# Remove the localhost entry from /etc/hosts
hostsfile_entry '127.0.1.1' do 
    action :remove
end

# Add the entry for the ipaddress
hostsfile_entry "#{node['ipaddress']}" do
    hostname "#{node['hostname']}"                                
    action :create
end
