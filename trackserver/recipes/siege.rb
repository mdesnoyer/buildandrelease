package 'siege'

template "/home/ubuntu/.siegerc" do
  source "siegerc.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0644"
  variables({})
end

template "/home/ubuntu/urls.txt" do
  source "trackserver_urls.txt.erb"
  owner "ubuntu"
  group "ubuntu"
  mode "0644"
  variables({:host => node[:neon][:siege][:trackserver_host]})
end

directory "/home/ubuntu/log" do
  :create
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
end
