# This recipe creates a hop serving that can be ssh'd to in order to
# access all the other serving systems in the VPC without needing a
# password. If you want to setup your local machine to ssh easily, you
# can add the following entry to your ~/.ssh/config file:
#
# Host hopserver
#   HostName <Elastic IP of this machine>
#   IdentityFile <Location to the ssh key for this machine>
#
# Host 10.0.*
#   ProxyCommand ssh -q hopserver nc -q0 %h 22


include_recipe "neon::default"

package "netcat6" do
  action :install
end

s3_file "/home/ubuntu/.ssh/emr.pem" do
  source node[:neon][:serving_key]
  owner "ubuntu"
  group "ubuntu"
  action :create
  mode "0600"
end
