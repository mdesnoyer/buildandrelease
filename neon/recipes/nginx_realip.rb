# This recipe downloads the AWS list of ip address blocks and then
# defines the nginx real ip variables to setup the nginx config
# properly to insert the real-ip header.

remote_file "#{Chef::Config[:file_cache_path]}/aws-ip-ranges.json" do
  source node[:aws][:ip_ranges_url]
  mode '755'
  action :nothing
end.run_action(:create)

# Force_Default is needed because these parameters are set in the nginx recipe
node.force_default[:nginx][:realip][:header] = "X-Forwarded-For"
node.force_default[:nginx][:realip][:real_ip_recursive] = "on"
node.force_default[:nginx][:realip][:addresses] = []

ip_ranges_json = JSON.parse(File.read("#{Chef::Config[:file_cache_path]}/aws-ip-ranges.json"))

ip_ranges_json["prefixes"].each do | prefix |
  if (prefix["service"] == "AMAZON" and 
      [node[:opsworks][:instance][:region], "GLOBAL"].include? prefix["region"])
  then
    node.force_default[:nginx][:realip][:addresses] << prefix["ip_prefix"]
  end
end
