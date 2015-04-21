# Cookbook Name:: cmsdb
# Recipe:: slave
#
# Creates a slave instance of redis
#
# Copyright 2015, Neon Labs Inc.
#
# All rights reserved - Do Not Redistribute
#

node.default[:cmsdb][:is_slave] = true
node.default[:redis][:slave_priority] = 0
node.default[:redis][:master_ip] = get_master_cmsdb_ip()
  
# Don't save anything to disk. No need to.
node.default[:redis][:snapshot_saves] = {'""' => ""}
node.default[:redis][:appendonly] = 'no'

# Open up the binding to come from anywhere
node.default[:redis][:bind_address] = "0.0.0.0"

include_recipe "cmsdb::default"
