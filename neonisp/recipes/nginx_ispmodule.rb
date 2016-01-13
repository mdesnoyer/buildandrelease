
repo_path = get_repo_path(node[:neonisp][:app_name])
node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{repo_path}/imageservingplatform/neon_isp", 
                                             "--add-module=#{repo_path}/imageservingplatform/ngx_devel_kit-0.2.19", 
                                             "--add-module=#{repo_path}/imageservingplatform/set-misc-nginx-module-0.29" 
                                            ]
