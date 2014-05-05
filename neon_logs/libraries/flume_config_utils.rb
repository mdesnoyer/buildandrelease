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

    # Returns a hash of collector ips based on the OpsWorks config.
    # The hash has two lists one [:primary] lists the ips in the
    # current availability zone, while [:backup] lists the ips in the
    # same region, but different availability zone.
    # The IP addresses are randomly sorted based on the current hostname
    def get_collector_ips()
      primary_ips = []
      backup_ips = []
      collector_instances = \
        node[:opsworks][:layers][node[:neon_logs][:collector_layer]][:instances]
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

    # Makes the aws key safe for writing to a URI. This is done by
    # replacing the '/' with %2F
    def escape_aws_key(key)
      Chef::Application.fatal!("AWS Credentials not set") if key.nil? or key.empty?
      return key.gsub("/", "%%2F")
    end
  end
end
