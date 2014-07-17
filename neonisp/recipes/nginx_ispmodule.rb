# Write the imageservingplatform configuration for nginx
template "#{node[:nginx][:dir]}/conf.d/neonisp.conf" do
  source "neonisp_nginx.conf.erb"
  owner node['nginx']['user']
  group node['nginx']['group']
  mode "0644"
  variables({
              :port => node[:neonisp][:port],
              :mastermind_validated_filepath => node[:neonisp][:mastermind_validated_filepath],
              :mastermind_file_url => node[:neonisp][:mastermind_file_url],
              :client_expires => node[:neonisp][:client_api_expiry]
            })
  notifies :reload, 'service[nginx]'
end

node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{node[:neon][:code_root]}/imageservingplatform/neon_isp"]
