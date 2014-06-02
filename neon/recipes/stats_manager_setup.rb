include_recipe "neon::repo"

pydeps = {
  "boto" => "2.29.1",
  "simplejson" => "2.3.2",
  "paramiko" => "1.14.0",
  "nose" => "1.3.0",
  "thrift" => "0.9.1",
}

# Create a statsmanager user
user "statsmanager" do
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

# Install the mail client
package "mailutils" do
  :install
end

# Grab the ssh identity file to talk to the cluster with
directory "#{node[:neon][:home]}/statsmanager/.ssh" do
  owner "statsmanager"
  group "statsmanager"
  action :create
  mode "0700"
  recursive true
end
s3_file "#{node[:neon][:home]}/statsmanager/.ssh/emr.pem" do
  source node[:neon][:emr_key]
  owner "statsmanager"
  group "statsmanager"
  action :create
  mode "0600"
end