# Helpful docs
# http://www.cloudera.com/content/cloudera/en/documentation/cdh4/v4-2-2/CDH4-Installation-Guide/cdh4ig_topic_20_5.html
# http://www.alexjf.net/blog/distributed-systems/hadoop-yarn-installation-definitive-guide/

# install java
include_recipe "java::default"

# install hadoop
include_recipe "hadoop::default"

# hdfs namenode
include_recipe "hadoop::hadoop_hdfs_namenode"

# hdfs datanode
include_recipe "hadoop::hadoop_hdfs_datanode"

# install hbase
include_recpie "hadoop::hbase"

# hbase master
include_recpie "hadoop::hbase_master"

# hbase regionserver
include_recpie "hadoop::hbase_regionserver"

# hbase REST
include_recpie "hadoop::hbase_rest"

# zookeeper client
include_recpie "hadoop::zookeeper"

# zookeeper server
include_recpie "hadoop::zookeeper_server"

# Create namenode dir
#
# may need to run this :: hadoop namenode -format
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
# datanode
# zookeeper
# hbase master
# hbase regionserver
