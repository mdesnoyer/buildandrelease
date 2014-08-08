include_attribute "neon::default"
include_attribute "neon-opencv"

# Pin the gflags version
default[:gflags][:version] = "2.1.0"
default[:gflags][:archive][:version] = node[:gflags][:version]
default[:gflags][:archive][:url] = "https://github.com/schuhschuh/gflags/archive/v#{node[:gflags][:archive][:version]}.tar.gz"
default[:gflags][:package][:url_base] = "https://github.com/schuhschuh/gflags/releases/download/v#{node[:gflags][:version]}/"

# Build opencv and its depdencies near the main repo
default[:opencv][:build_path] = "#{node[:neon][:home]}/opencv"
default[:yasm][:build_path] = "#{node[:neon][:home]}/yasm"
default[:x264][:build_path] = "#{node[:neon][:home]}/x264"
default[:libvpx][:build_path] = "#{node[:neon][:home]}/libvpx"
default[:ffmpeg][:build_path] = "#{node[:neon][:home]}/ffmpeg"
