# Helpful docs
# http://www.cloudera.com/content/cloudera/en/documentation/cdh4/v4-2-2/CDH4-Installation-Guide/cdh4ig_topic_20_5.html
# http://www.alexjf.net/blog/distributed-systems/hadoop-yarn-installation-definitive-guide/

# install java
include_recipe "java::default"

node.default[:hadoop][:distribution] = 'cdh'
node.default[:hadoop][:distribution_version] = '5'

# install hadoop
include_recipe "hadoop::default"

# hdfs namenode
include_recipe "hadoop::hadoop_hdfs_namenode"

# hdfs datanode
include_recipe "hadoop::hadoop_hdfs_datanode"

# install hbase
include_recipe "hadoop::hbase"

# hbase master
include_recipe "hadoop::hbase_master"

# hbase regionserver
include_recipe "hadoop::hbase_regionserver"

# hbase REST
include_recipe "hadoop::hbase_rest"

# zookeeper client
include_recipe "hadoop::zookeeper"

# zookeeper server
include_recipe "hadoop::zookeeper_server"

# Create namenode dir
#
# may need to run this :: hadoop namenode -format
# TODO: What if the name node dir is already full ?

execute 'hdfs-namenode-format' do
  command 'hdfs namenode -format -nonInteractive' + (node['hadoop']['force_format'] ? ' -force' : '')
  action :run
  group 'hdfs'
  user 'hdfs'
end


#
# Creare data node dir
#


# Ensure both dirs have the right permissions
#
#

# Create the hbase mount
# hadoop fs -mkdir hdfs://<IP>:8020/

# ensure its owned by hbase user
# hadoop fs -chown -R hbase:hbase hdfs://<IP>:8020/hbase


# Start all the services in this order
#

# namenode
service 'hadoop-hdfs-namenode' do
    action [:enable, :restart]
end

# datanode
service 'hadoop-hdfs-datanode' do
    action [:enable, :restart]
end

# zookeeper
service 'zookeeper-server' do
    action [:enable, :start]
end

# hbase master
service 'hbase-master' do
    action [:enable, :start]
end

# hbase regionserver
service 'hbase-regionserver' do
    action [:enable, :start]
end
