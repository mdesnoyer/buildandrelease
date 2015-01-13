# Remove the localhost entry from /etc/hosts
hostsfile_entry '127.0.1.1' do 
    action :nothing
    subscribes :remove, "template[/etc/hosts]", :immediately
end

# Add the entry for the ipaddress
hostsfile_entry "#{node['ipaddress']}" do 
    hostname "#{node['hostname']}" 
    action :nothing
    subscribes :create, "hostsfile_entry[127.0.1.1]", :immediately
end
