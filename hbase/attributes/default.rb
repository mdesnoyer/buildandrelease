# hadoop configs
#
default[:hadoop][:core_site]['fs.defaultFS'] = "#{node['hostname']}"

#
#
default['hbase']['hbase_site']['hbase.rootdir'] = "#{node['hadoop']['core_site']['fs.defaultFS']}/hbase"

# hbase site-xml config
# Replace "hbase1" with the IP address of the server being spun up
default[:hbase][:hbase_site]['hbase.cluster.distributed'] = true 
default[:hbase][:hbase_site]['hbase.rootdir'] = "hdfs://#{node['hostname']}:8020"
default[:hbase][:hbase_site]['hbase.zookeeper.quorum'] = "#{node['hostname']}" 
default[:hbase][:hbase_site]['hbase.regionserver.ipc.address'] = "hbase1"
default[:hbase][:hbase_site]['hbase.master.ipc.address'] = "#{node['hostname']}" 
default[:hbase][:hbase_site]['zookeeper.znode.parent'] = "/tmp/hbase" 
default[:hbase][:hbase_site]['zookeeper.property.clientPort'] = "2181" 

# zookeepr config 
default[:zookeeper][:zoocfg]['zookeeper.znode.parent'] = default[:hbase][:hbase_site]['zookeeper.znode.parent']  

    
