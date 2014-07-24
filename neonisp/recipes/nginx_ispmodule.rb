
repo_path = get_repo_path("Image Serving Platform")
node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=#{repo_path}/imageservingplatform/neon_isp"]
