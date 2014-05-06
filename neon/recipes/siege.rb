package 'siege'

if node[:opsworks][:activity] == 'configure' then
  template "/home/ubuntu/.siegerc" do
    source "siegerc.erb"
    owner "ubuntu"
    group "ubuntu"
    mode "0644"
    variables({})
  end

  template "/home/ubuntu/urls.txt" do
    source "trackserver_urls.txt.erb"
    owner "ubunutu"
    group "ubuntu"
    mode "0644"
    variables({:host => node[:neon][:siege][:trackserver_host]})
  end

end
