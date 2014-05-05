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

    # Returns the directory where the flume logs will live
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
    def get_fileagent_config(filename, collector_layer=nil,
                             collector_port=nil)
      namespace = "fa_#{File.basename(filename)}"
      collector_ips = get_collector_ips(collector_layer)
      ncollectors = collector_ips[:primary].length + collector_ips[:backup].length
      # Determine all the sinks based on the collector ips
      sinks = []
      collector_ips[:primary].each.with_index do |ip, idx|
        sinks << {
          :name => '#{namespace}_pk_#{idx}',
          :ip => ip,
          :priority => ncollectors - idx
        }
      end
      collector_ips[:backup].each.with_index do |ip, idx|
        sinks << {
          :name => '#{namespace}_bk_#{idx}',
          :ip => ip,
          :priority => ncollectors - idx - collector_ips[:primary].length
        }
      end

      return {
        :sources => ['#{namespace}_s'],
        :channels => ['#{namespace}_c'],
        :sinks => sinks.map{|x| x[:name]},
        :sinkgroups => ['#{namespace}_kg'],
        :template => 'filelog_agent.conf.erb',
        :variables => {
          :s => '#{namespace}_s',
          :c => '#{namespace}_c',
          :kg => '#{namespace}_kg',
          :sinks => sinks,
          :source_file => filename,
          :collector_port => collector_port,
          :hostname => node[:hostname]
        }
      }
    end

    # Returns a hash of collector ips based on the OpsWorks config.
    # The hash has two lists one [:primary] lists the ips in the
    # current availability zone, while [:backup] lists the ips in the
    # same region, but different availability zone.
    # The IP addresses are randomly sorted based on the current hostname
    def get_collector_ips(collector_layer)
      primary_ips = []
      backup_ips = []
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
