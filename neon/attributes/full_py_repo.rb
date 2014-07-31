
# Pin the gflags version
default[:gflags][:version] = "2.1.0"
default[:gflags][:archive][:version] = node[:gflags][:version]
default[:gflags][:archive][:url] = "https://github.com/schuhschuh/gflags/archive/v#{node[:gflags][:archive][:version]}.tar.gz"
default[:gflags][:package][:url_base] = "https://github.com/schuhschuh/gflags/releases/download/v#{node[:gflags][:version]}/"
