#
# Cookbook Name:: neon-opencv
# Recipe:: install
# Author:: Mark Desnoyer <desnoyer@neon-lab.com>
#
# Copyright 2014, Neon Labs Inc.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'
include_recipe 'build-essential'

package "cmake" do
  action :install
end

# List the dependencies
package_deps = [
    'libjpeg-dev',
    'libjasper-dev',
    'libtheora-dev',
    'libxvidcore-dev',
    'libtiff4-dev',
    'libpng-dev',
    'libfdk-aac-dev',
]

cmake_params = {
  "CMAKE_INSTALL_PREFIX" => node[:opencv][:install_prefix],
  "CMAKE_BUILD_TYPE" => "RELEASE",
}

# Add extra options
if node[:opencv][:with_firewire] then
  package_deps = package_deps + [ 'libdc1394-22-dev']
end
if node[:opencv][:with_qt] then
  package_deps = package_deps + [ 'libqt4-dev' ]
  cmake_params["WITH_QT"] = "ON"
else
  package_deps = package_deps + [ 'libgtk2.0-dev' ]
end
if node[:opencv][:with_gstreamer] then
  package_deps = package_deps +
    [ 'libgstreamer0.10-dev', 'libgstreamer-plugins-base0.10-dev' ]
end
if node[:opencv][:with_v4l] then
  package_deps = package_deps + [ 'libv4l-dev', ' v4l-utils' ]
  cmake_params["WITH_V4L"] = "ON"
end
if node[:opencv][:with_tbb] then
  package_deps = package_deps + [ 'libtbb-dev' ]
  cmake_params["WITH_TBB"] = "ON"
end
if node[:opencv][:with_python] then
  package_deps = package_deps +
    [ 'python-dev',
      'python-numpy'
    ]
  cmake_params["BUILD_NEW_PYTHON_SUPPORT"] = "ON"
end

# Install the depdencencies
package_deps.each do | pkg |
  package pkg do
    action :install
  end
end

# Install yasm from source
node.default[:yasm][:git_revision] = "v1.2.0"
node.default[:yasm][:install_method] = "source"

# Pin the x264 version
node.default[:x264][:git_revision] = "af8e768e2bd3b4398bca033998f83b0eb8874914"
node.default[:x264][:compile_flags] = ["--enable-shared", "--enable-pic"]

# Pin the libvpx version
node.default[:libvpx][:git_revision] = "v1.3.0"
node.default[:libvpx][:compile_flags] = ["--enable-shared", "--enable-pic"]

# Install the depdencencies
package_deps.each do | pkg |
  package pkg do
    action :install
  end
end

# Install ffmpeg
node.default[:ffmpeg][:git_repository] = 'https://github.com/FFmpeg/FFmpeg.git'
node.default[:ffmpeg][:git_revision] = 'n2.8'
node.default[:ffmpeg][:compile_flags] = [
    "--enable-pthreads",
    "--disable-indev=jack",
    "--enable-libx264",
    "--enable-libtheora",
    "--enable-libvpx",
    "--enable-libxvid",
    "--enable-gpl",
    "--enable-version3",
    "--enable-shared",
    "--enable-pic",
    "--enable-libfdk-aac",
    "--enable-nonfree",
]
include_recipe "ffmpeg::source"

opencv_include = "#{node[:opencv][:install_prefix]}/include/opencv2/core/core.hpp"
file opencv_include do
  action :nothing
  subscribes :delete, "bash[compile_ffmpeg]", :immediately
end

# Create the build directory
git node[:opencv][:build_dir] do
  repository node[:opencv][:repo]
  revision node[:opencv][:version]
  action :sync
  notifies :delete, "file[#{opencv_include}]", :immediately
end
directory "#{node[:opencv][:build_dir]}/build" do
  action :create
end

if node[:opencv][:include_contrib] then
  git node[:opencv][:contrib_dir] do
    repository node[:opencv][:contrib_repo]
    revision node[:opencv][:contrib_version]
    action :sync
    notifies :delete, "file[#{opencv_include}]", :immediately
  end
  cmake_params["OPENCV_EXTRA_MODULES_PATH"] = "#{node[:opencv][:contrib_dir]}/modules"
end

# Write the build configuration to a file - if it changes, we recompile
template "#{node[:opencv][:build_dir]}/opencv-build-configuration" do
    source "build-configuration.erb"
    owner "root"
    group "root"
    mode 0600
    variables(
        :package_deps => package_deps,
        :cmake_params => cmake_params
    )
    notifies :delete, "file[#{opencv_include}]", :immediately
end

# Compile OpenCV
cmake_args = cmake_params.each.map{|k,v| "-D #{k}=#{v}"}.join(" ")
bash "compile_opencv" do
  cwd "#{node[:opencv][:build_dir]}/build"
  code <<-EOH
       cmake #{cmake_args} ..
       make clean && make -j#{node[:cpu][:total]} && make install
  EOH
  not_if {  ::File.exists?(opencv_include) }
end
