class Chef
  class Recipe

    # Returns the ip of the CMS db master node
    def get_master_cmsdb_ip()
      if node[:cmsdb][:master_ip].nil?
        return get_first_host_in_layer(node[:cmsdb][:master_layer],
                                       node[:cmsdb][:master_fallback_host])
      end
      return node[:cmsdb][:master_ip]
    end

  end
end
