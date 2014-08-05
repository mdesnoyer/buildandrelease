
repo_path = get_repo_path(node[:neonisp][:app_name])
node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{repo_path}/imageservingplatform/neon_isp"]
