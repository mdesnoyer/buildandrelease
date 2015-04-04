# Cookbook Name:: cmsdb
# Recipe:: slave
#
# Creates a slave instance of redis
#
# Copyright 2015, Neon Labs Inc.
#
# All rights reserved - Do Not Redistribute
#

default.node[:cmsdb][:is_slave] = true
include_recipe "cmsdb::default"
