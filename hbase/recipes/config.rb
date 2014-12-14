# Remove the localhost entry from /etc/hosts
hostsfile_entry '127.0.1.1' do 
    action :remove
end
