# hbase/ hadoop configs to spin up hbase server in a pseduo distributed mode 
 
#
default[:hadoop][:core_site]['fs.defaultFS'] = "#{node['hostname']}"
default[:hadoop][:hdfs_site]['dfs.datanode.data.dir'] = "/mnt/datanode"
default[:hadoop][:hdfs_site]['dfs.namenode.name.dir'] = "/mnt/namenode"

#
#
# hbase site-xml config
# Replace "hbase1" with the IP address of the server being spun up
default[:hbase][:hbase_site]['hbase.cluster.distributed'] = true 
default[:hbase][:hbase_site]['hbase.rootdir'] = "hdfs://#{node['hostname']}:8020/hbase"
default[:hbase][:hbase_site]['hbase.zookeeper.quorum'] = "#{node['hostname']}" 
default[:hbase][:hbase_site]['hbase.regionserver.ipc.address'] = "#{node['hostname']}" 
default[:hbase][:hbase_site]['hbase.master.ipc.address'] = "#{node['hostname']}" 
default[:hbase][:hbase_site]['zookeeper.znode.parent'] = "/tmp/hbase" 
default[:hbase][:hbase_site]['zookeeper.property.clientPort'] = "2181" 
default[:hbase][:hbase_tables] = ["THUMBNAIL_TIMESTAMP_EVENTS", "TIMESTAMP_THUMBNAIL_EVENTS"]
default[:hbase][:hbase_cfamily] = "THUMBNAIL_EVENTS_TYPES"


# zookeepr config 
default[:zookeeper][:zoocfg]['zookeeper.znode.parent'] = default[:hbase][:hbase_site]['zookeeper.znode.parent']  

    
