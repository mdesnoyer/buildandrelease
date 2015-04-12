include_attribute "neon::default"
include_attribute "neon-opencv"
include_attribute "yasm"
include_attribute "libvpx"
include_attribute "x264"
include_attribute "ffmpeg"

# Pin the gflags version
default[:gflags][:version] = "2.1.0"
default[:gflags][:archive][:version] = node[:gflags][:version]
default[:gflags][:archive][:url] = "https://github.com/schuhschuh/gflags/archive/v#{node[:gflags][:archive][:version]}.tar.gz"
default[:gflags][:package][:url_base] = "https://github.com/schuhschuh/gflags/releases/download/v#{node[:gflags][:version]}/"

# Build opencv and its depdencies near the main repo
default[:opencv][:build_dir] = "#{node[:neon][:home]}/opencv"
default[:yasm][:build_dir] = "#{node[:neon][:home]}/yasm"
default[:x264][:build_dir] = "#{node[:neon][:home]}/x264"
default[:libvpx][:build_dir] = "#{node[:neon][:home]}/libvpx"
default[:ffmpeg][:build_dir] = "#{node[:neon][:home]}/ffmpeg"

default[:neon][:redis_pkg_link] = "https://neon-dependencies.s3.amazonaws.com/redis-2.8.4.ubuntu.12.04_amd64.deb"
default[:neon][:redis_version] = "2.8.4"
