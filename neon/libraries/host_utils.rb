class Chef
  class Recipe

    # Returns the ip address of a host on a specific layer. Defaults
    # to the one in the current availability zone if there is more than one.
    def get_host_in_layer(layer_name, fallback_host)
      primary_hosts = []
      fallback_hosts = []
      layer = node[:opsworks][:layers][layer_name]
      if layer.nil?
        Chef::Log.warn "Could not find layer #{layer_name}. Falling back to host #{fallback_host}"
        return fallback_host
      end

      video_db_layer[:instances].each do |name, instance|
        if (instance[:availability_zone] == 
            node[:opsworks][:instance][:availability_zone]) then
          primary_hosts << instance[:private_ip]
        else
          fallback_hosts << instance[:private_ip]
        end
      end

      if primary_hosts.length > 0 then
        return primary_hosts.sample(random: Random.new(node[:hostname].hash))
      elsif fallback_hosts.length > 0 then
        return fallback_hosts.sample(random: Random.new(node[:hostname].hash))
      else
        Chef::Log.warn "Could not find a valid host in layer #{layer_name}. Falling back to host #{fallback_host}"
        return fallback_host
      end
    end
  end
end
