#
# Cookbook Name:: cmsdb
# Recipe:: default
#
# Copyright 2015, Neon Labs Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe "neon::default"
include_recipe "neon::system_metrics"

# Install redis
if node[:cmsdb][:is_slave] then
  node.default[:redis][:slave_priority] = 0
  node.default[:redis][:master_ip] = get_master_cmsdb_ip()
  
  # Don't save anything to disk. No need to.
  node.default[:redis][:snapshot_saves] = {'""' => ""}
  node.default[:redis][:appendonly] = 'no'
end
include_recipe "redis::default"

if not node[:cmsdb][:is_slave] then
  # Setup the cron to backup the database file
  include_recipe "awscli"

  cron "backup_redis" do
    hour '1'
    minute '12'
    user 'redis'
    mailto 'ops@neon-lab.com'
    command "aws s3 cp #{node[:redis][:db_dir]}/#{node[:redis][:dbfilename]} s3://#{node[:cmsdb][:backup_s3_bucket]}/#{node[:hostname]}/`date +\%F-\%H-\%M-\%S`.rdb"
  end
end
    
