class Chef
  class Recipe

    # Returns the directory where the flume config will live
    def get_config_dir()
      "#{node[:neon_logs][:flume_conf_dir]}/#{node[:neon_logs][:flume_service_name]}"
    end

    # Returns the directory where the flume logs will live
    def get_log_dir()
      "#{node[:neon_logs][:flume_log_dir]}/#{node[:neon_logs][:flume_service_name]}"
    end

    # Returns the directory where the flume proceedure will run
    def get_run_dir()
      "#{node[:neon_logs][:flume_run_dir]}/#{node[:neon_logs][:flume_service_name]}"
    end

    def get_service_bin()
      "/etc/init.d/#{node[:neon_logs][:flume_service_name]}"
    end

    # Returns the configuration variables necessary to setup flume to
    # read (aka tail) from a given file and output those logs.
    #
    # Inputs:
    # filename - Name of the file to watch
    # collector_layer - Name of the collector layer in OpsWorks
    # collector_port - Port that the collector is listening on
    # log_type - Name of the log type
    def get_fileagent_config(filename, log_type=nil, collector_layer=nil,
                             collector_port=nil)
      collector_port = collector_port || node[:neon_logs][:collector_port]
      log_type = log_type || node[:neon_logs][:log_type]

      namespace = "fa_#{File.basename(filename).split('.')[0]}"
      collector_ips = get_collector_ips(collector_layer)
      ncollectors = collector_ips[:primary].length + collector_ips[:backup].length
      if ncollectors == 0
        Chef::Log.warn "No collectors found for log_type: #{log_type}"
        return {}
      end
      # Determine all the sinks based on the collector ips
      sinks = []
      collector_ips[:primary].each.with_index do |ip, idx|
        sinks << {
          :name => "#{namespace}_pk_#{idx}",
          :ip => ip,
          :priority => ncollectors - idx
        }
      end
      collector_ips[:backup].each.with_index do |ip, idx|
        sinks << {
          :name => "#{namespace}_bk_#{idx}",
          :ip => ip,
          :priority => ncollectors - idx - collector_ips[:primary].length
        }
      end

      return {
        :sources => ["#{namespace}_s"],
        :channels => ["#{namespace}_c"],
        :sinks => sinks.map{|x| x[:name]},
        :sinkgroups => ["#{namespace}_kg"],
        :template => 'filelog_agent.conf.erb',
        :variables => {
          :s => "#{namespace}_s",
          :c => "#{namespace}_c",
          :kg => "#{namespace}_kg",
          :sinks => sinks,
          :source_file => filename,
          :collector_port => collector_port,
          :hostname => node[:hostname],
          :log_type => log_type
        }
      }
    end

    # Returns the configuration variables necessary to setup flume to
    # listen to an http port for json data.
    #
    # Inputs:
    # json_port - Port to listen for json data on
    # collector_layer - Name of the collector layer in OpsWorks
    # collector_port - Port that the collector is listening on
    # log_type - Name of the log type
    def get_jsonagent_config(json_port=nil, log_type=nil, collector_layer=nil,
                             collector_port=nil)
      json_port = json_port || node[:neon_logs][:json_http_source_port]
      collector_port = collector_port || node[:neon_logs][:collector_port]
      log_type = log_type || node[:neon_logs][:log_type]

      namespace = "ja_#{json_port}"
      collector_ips = get_collector_ips(collector_layer)
      ncollectors = collector_ips[:primary].length + collector_ips[:backup].length
      if ncollectors == 0
        Chef::Log.warn "No collectors found for log_type: #{log_type}"
        return {}
      end
      # Determine all the sinks based on the collector ips
      sinks = []
      collector_ips[:primary].each.with_index do |ip, idx|
        sinks << {
          :name => "#{namespace}_pk_#{idx}",
          :ip => ip,
          :priority => ncollectors - idx
        }
      end
      collector_ips[:backup].each.with_index do |ip, idx|
        sinks << {
          :name => "#{namespace}_bk_#{idx}",
          :ip => ip,
          :priority => ncollectors - idx - collector_ips[:primary].length
        }
      end

      return {
        :sources => ["#{namespace}_s"],
        :channels => ["#{namespace}_c"],
        :sinks => sinks.map{|x| x[:name]},
        :sinkgroups => ["#{namespace}_kg"],
        :template => 'json_agent.conf.erb',
        :variables => {
          :s => "#{namespace}_s",
          :c => "#{namespace}_c",
          :kg => "#{namespace}_kg",
          :sinks => sinks,
          :json_port => json_port,
          :collector_port => collector_port,
          :hostname => node[:hostname],
          :log_type => log_type
        }
      }
    end

    def get_thriftagent_config(thrift_port=nil, log_type=nil,
                               collector_layer=nil, collector_port=nil)
      thrift_port = thrift_port || node[:neon_logs][:thrift_source_port]
      collector_port = collector_port || node[:neon_logs][:collector_port]
      log_type = log_type || node[:neon_logs][:log_type]

      namespace = "ta_#{thrift_port}"
      collector_ips = get_collector_ips(collector_layer)
      ncollectors = collector_ips[:primary].length + collector_ips[:backup].length
      if ncollectors == 0
        Chef::Log.warn "No collectors found for log_type: #{log_type}"
        return {}
      end
      # Determine all the sinks based on the collector ips
      sinks = []
      collector_ips[:primary].each.with_index do |ip, idx|
        sinks << {
          :name => "#{namespace}_pk_#{idx}",
          :ip => ip,
          :priority => ncollectors - idx
        }
      end
      collector_ips[:backup].each.with_index do |ip, idx|
        sinks << {
          :name => "#{namespace}_bk_#{idx}",
          :ip => ip,
          :priority => ncollectors - idx - collector_ips[:primary].length
        }
      end

      return {
        :sources => ["#{namespace}_s"],
        :channels => ["#{namespace}_c"],
        :sinks => sinks.map{|x| x[:name]},
        :sinkgroups => ["#{namespace}_kg"],
        :template => 'thrift_agent.conf.erb',
        :variables => {
          :s => "#{namespace}_s",
          :c => "#{namespace}_c",
          :kg => "#{namespace}_kg",
          :sinks => sinks,
          :thrift_port => thrift_port,
          :collector_port => collector_port,
          :hostname => node[:hostname],
          :log_type => log_type
        }
      }
    end

    # Returns the configuration variables necessary to setup flume to
    # act as a log collector
    #
    # Inputs:
    # listen_port - Port to listen on
    # channel_path - Location on disk for the file channel
    # s3_log_path - The HDFS path to write to s3. See log HDFS sink for more 
    #               details.
    # max_log_size - The maximum log size in bytes per file
    # max_log_rolltime - The maximum rollover interval in seconds
    # s3_flush_batch_size - The size of batches before writing to s3
    # compression - The compression type to write to s3 with
    # log_type - Name of the log type being collected
    def get_logcollector_config(listen_port=nil,
                                s3_log_path=nil,
                                log_type=nil,
                                max_log_size=nil,
                                max_log_rolltime=nil,
                                s3_flush_batch_size=nil,
                                compression=nil,
                                output_serializer=nil)
      listen_port = listen_port || node[:neon_logs][:collector_port]
      s3_log_path = s3_log_path || node[:neon_logs][:s3_log_path]
      max_log_size = max_log_size || node[:neon_logs][:max_log_size]
      max_log_rolltime = max_log_rolltime || node[:neon_logs][:max_log_rolltime]
      s3_flush_batch_size = s3_flush_batch_size || node[:neon_logs][:s3_flush_batch_size]
      compression = compression || node[:neon_logs][:s3_log_compression]
      log_type = log_type || node[:neon_logs][:log_type]
      output_serializer = output_serializer || node[:neon_logs][:s3_output_serializer]

      namespace = "lc_#{log_type}"

      return {
        :sources => ["#{namespace}_s"],
        :channels => ["#{namespace}_c"],
        :sinks => ["#{namespace}_k"],
        :sinkgroups => [],
        :template => 'log_collector.conf.erb',
        :variables => {
          :s => "#{namespace}_s",
          :c => "#{namespace}_c",
          :k => "#{namespace}_k",
          :collector_port => listen_port,
          :collector_host => node[:opsworks][:instance][:private_ip],
          :s3_log_path => s3_log_path,
          :max_log_size => max_log_size,
          :max_log_rolltime => max_log_rolltime,
          :s3_flush_batch_size => s3_flush_batch_size,
          :compression => compression,
          :log_type => log_type,
          :output_serializer => output_serializer
        }
      }
    end
    
    # Flume config necessary to setup log collector  with HBase
    # It has a single source, 2 channels, 2 sinks
    # hbase_flush_batch_size : 
    # hbase_table_name : The table name for the sink
    # hbase_c_family : The column family for the sink operations
    # hbase_columns : Individual columns in the column family
    # hbase_serialize : The java pkg name for the hbase sink serializer
    # other inputs are same as above in get_logcollector_config
    # 
    def get_collector_with_hbasesink_config(listen_port=nil,
                                log_type=nil,
                                max_log_size=nil,
                                max_log_rolltime=nil,
                                s3_flush_batch_size=nil,
                                compression=nil,
                                s3_output_serializer=nil,
                                hbase_flush_batch_size=nil,
                                hbase_table_name=nil,
                                hbase_c_family=nil,
                                hbase_columns=nil,
                                hbase_serializer=nil)
      
      listen_port = listen_port || node[:neon_logs][:collector_port]
      s3_log_path = s3_log_path || node[:neon_logs][:s3_log_path]
      max_log_size = max_log_size || node[:neon_logs][:max_log_size]
      max_log_rolltime = max_log_rolltime || node[:neon_logs][:max_log_rolltime]
      s3_flush_batch_size = s3_flush_batch_size || node[:neon_logs][:s3_flush_batch_size]
      compression = compression || node[:neon_logs][:s3_log_compression]
      s3_output_serializer = s3_output_serializer || node[:neon_logs][:s3_output_serializer]
      log_type = log_type || node[:neon_logs][:log_type]

      collector_namespace = "lc_#{log_type}" 
      hbase_namespace = "lc_hbasesink" 
      
      return {
        :sources => ["#{collector_namespace}_s"],
        :channels => ["#{collector_namespace}_c", "#{hbase_namespace}_c"],
        :sinks => ["#{collector_namespace}_k", "#{hbase_namespace}_k"],
        :sinkgroups => [],
        :template => 'hbase_sink.conf.erb',
        :variables => {
          :cs => "#{collector_namespace}_s",
          :cc => "#{collector_namespace}_c",
          :ck => "#{collector_namespace}_k",
          :hs => "#{hbase_namespace}_s",
          :hc => "#{hbase_namespace}_c",
          :hk => "#{hbase_namespace}_k",
          :collector_port => listen_port,
          :collector_host => node[:opsworks][:instance][:private_ip],
          :s3_log_path => s3_log_path,
          :max_log_size => max_log_size,
          :max_log_rolltime => max_log_rolltime,
          :s3_flush_batch_size => s3_flush_batch_size,
          :compression => compression,
          :log_type => log_type,
          :s3_output_serializer => s3_output_serializer,
          :hbase_flush_batch_size => hbase_flush_batch_size,
          :hbase_table => hbase_table_name,
          :hbase_cf => hbase_c_family,
          :hbase_columns => hbase_columns,
          :hbase_serializer => hbase_serializer,
        }
      }
    end

    # Returns a hash of collector ips based on the OpsWorks config.
    # The hash has two lists one [:primary] lists the ips in the
    # current availability zone, while [:backup] lists the ips in the
    # same region, but different availability zone.
    # The IP addresses are randomly sorted based on the current hostname
    def get_collector_ips(collector_layer=nil)
      collector_layer = collector_layer || node[:neon_logs][:collector_layer]
      primary_ips = []
      backup_ips = []
      Chef::Log.info "Looking for collectors in layer: #{collector_layer}"
      collector_instances = \
        node[:opsworks][:layers][collector_layer][:instances]
      collector_instances.each do |name, collector|
        if (collector[:availability_zone] == 
            node[:opsworks][:instance][:availability_zone]) then
          primary_ips << collector[:private_ip]
        elsif collector[:region] == node[:opsworks][:instance][:region] then
          backup_ips << collector[:private_ip]
        end
      end

      primary_ips = primary_ips.shuffle(random: Random.new(node[:hostname].hash))
      backup_ips = backup_ips.shuffle(random: Random.new(node[:hostname].hash))

      return {:primary => primary_ips, :backup => backup_ips}
    end
  end
end
