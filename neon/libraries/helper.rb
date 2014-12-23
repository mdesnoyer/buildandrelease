class Chef
  class Recipe

    # Get the first server encountered in the layer which is in the 
    # same availability zone. 
    #
    # NOTE: Helpful to find single server in a layer like Redis, hbase etc 
    # @server_layer_name: opsworks layer name to find server in
    # @fallback_host: if server is not found, use this as fallback hostname
    def get_server_in_layer(server_layer_name, fallback_host)
        Chef::Log.info "Looking for the server in layer: #{server_layer_name}"
        server_host = nil
        server_layer = node[:opsworks][:layers]["#{server_layer_name}"]
        if server_layer.nil?
          server_host = "#{fallback_host}"
        else
            server_layer[:instances].each do |name, instance|
            if (instance[:availability_zone] == 
                node[:opsworks][:instance][:availability_zone] or 
                    server_host.nil?) then
                server_host = instance[:private_ip]
            end
          end
        end
      Chef::Log.info "Returning server : #{server_host}"
      return server_host 
    end
  end
end
