# Helpful docs
# http://www.cloudera.com/content/cloudera/en/documentation/cdh4/v4-2-2/CDH4-Installation-Guide/cdh4ig_topic_20_5.html
# http://www.alexjf.net/blog/distributed-systems/hadoop-yarn-installation-definitive-guide/

# Install python
node.default[:python][:version] = '2.7.5'
include_recipe "python"

pydeps = {
  "thrift" => "0.9.1",
  "psutil" => "1.2.1"
}

pydeps.each do |package, vers|
  python_pip package do
    version vers
    options "--no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html"
  end
end

# Remove the localhost entry from /etc/hosts
# TODO: Make this a function
hostsfile_entry '127.0.1.1' do 
    action :nothing
    subscribes :remove, "template[/etc/hosts]", :immediately
end

# Add the entry for the ipaddress
hostsfile_entry "#{node['ipaddress']}" do 
    hostname "#{node['hostname']}" 
    action :nothing
    subscribes :create, "hostsfile_entry[127.0.1.1]", :immediately
end

# install java
include_recipe "java::default"

node.default[:hadoop][:distribution] = 'cdh'
node.default[:hadoop][:distribution_version] = '5'

node[:deploy].each do |app_name, deploy|
  if app_name != "hbase" then
    next
  end

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

  # hbase thrift
  include_recipe "hadoop::hbase_thrift"

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
    action :run
    not_if {  ::File.exists?('/mnt/namenode') }
  end


  # Start all the services in this order

  # namenode
  service 'hadoop-hdfs-namenode' do
    action [:enable, :restart]
  end

  # datanode
  service 'hadoop-hdfs-datanode' do
    action [:enable, :restart]
  end


  # format/setup the hdfs rootdir for hbase
  execute 'hbase-hdfs-rootdir' do
    action :run
  end

  # Initialize zookeeper
  bash "initialize_zookeeper" do
    user "root"
    group "root"
    code <<-EOH
      /etc/init.d/zookeeper-server init --force 
      EOH
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
    
  # hbase rest server (may be useful in the future)  
  # service 'hbase-rest' do
  #    action [:enable, :start]
  #end

    # Create the HBase tables and column families, wait for HMaster so sleep for 30secs
    # NOTE: this is how they seem to do it the opentsdb recipe
    execute "create hbase tables" do
        command "sleep 30 && echo \"create 'THUMBNAIL_TIMESTAMP_EVENT_COUNTS', 'evts'\" | /usr/bin/hbase shell  >> /var/log/hbase.create_tables.log 2>&1 && echo \"create 'TIMESTAMP_THUMBNAIL_EVENT_COUNTS', 'evts'\" | /usr/bin/hbase shell >> /var/log/hbase.create_tables.log 2>&1"
    end

    # hbase thrift server 
    service 'hbase-thrift' do
        action [:enable, :start]
    end


    # monitoring scripts

    # write the mointoring script to /usr/local/bin 
    template "/usr/local/bin/check_hbase_services.py" do  
        source "check_hbase_services.py.erb"
        owner "root"
        group "root"
        mode "0744"
        variables({:carbon_server => "54.225.235.97",
                   :carbon_port => 8090})
    end

    # write the upstart config file 
    template "/etc/init/hbase-metrics.conf" do
        source "check_hbase_upstart_service.conf.erb"
        owner "root"
        group "root"
        mode "0644"
        variables({:monitoring_script_path => "/usr/local/bin/check_hbase_services.py"})
    end

    # start monitoring service
    service "hbase-metrics" do
        provider Chef::Provider::Service::Upstart
        supports :status => true, :restart => true, :start => true, :stop => true
        action [:enable, :start]
    end

end
