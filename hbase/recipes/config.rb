#
## A working hbase-site.xml looks like follows
##
#
###
#<configuration>
#      <name>hbase.zookeeper.property.clientPort</name>
#      <value>2181</value>
#    </property>
#    <property>
#      <name>zookeeper.znode.parent</name>
#      <value>/tmp/hbase</value>
#    </property>
#    <property>
#      <name>hbase.zookeeper.quorum</name>
#      <value>10.0.78.0</value>
#    </property>
#    <property>
#    <name>hbase.regionserver.ipc.address</name>
#    <value>10.0.78.0</value>
#    </property> 
#    <property>
#    <name>hbase.master.ipc.address</name>
#    <value>10.0.78.0</value>
#    </property> 
#</configuration>
###
#
## zoo.cfg
#clientPort=2181
#dataDir=/var/lib/zookeeper
#dataLogDir=/var/lib/zookeeper
#zookeeper.znode.parent=/tmp/hbase
#
## hadoop xmls
## core-site
#<configuration>
#    <property>
#      <name>fs.defaultFS</name>
#      <value>hdfs://10.0.78.0</value>
#    </property>
#</configuration>
#
#
## hdfs-site.xml 
#
#<configuration>
#    <property>
#      <name>dfs.datanode.max.transfer.threads</name>
#      <value>8096</value>
#    </property>
#
#    <property>
#        <name>dfs.datanode.data.dir</name>
#        <value>file:///tmp/datanode</value>
#    </property>
#
#    <property>
#        <name>dfs.namenode.name.dir</name>
#        <value>file:///tmp/namenode</value>
#    </property>
#
#
#</configuration>
#
##yarn
#<configuration>
#    <property>
#      <name>yarn.resourcemanager.hostname</name>
#      <value>10.0.78.0</value>
#    </property>
#    <property>
#        <name>yarn.scheduler.minimum-allocation-mb</name>
#        <value>128</value>
#    </property>
#    <property>
#        <name>yarn.scheduler.maximum-allocation-mb</name>
#        <value>2048</value>
#    </property>
#</configuration>
