#
# Cookbook Name:: caffe
# Recipe:: default
#
# Copyright (c) 2015 Neon Labs, All Rights Reserved.

include_recipe "neon::default"
#include_recipe "yasm::source"
include_recipe "build-essential"
include_recipe "git"
include_recipe "neon::full_py_repo"
include_recipe "python::virtualenv"

software_dir = node[:caffe][:software_dir]
remote_dir = node[:caffe][:remote_dir]
local_user = node[:caffe][:local_user]
local_group = node[:caffe][:local_group]
install_interactive = node[:caffe][:install_interactive]
# remote files
glog_filename = "#{node["caffe"]["glog_tarball_name_wo_tgz"]}.tar.gz"
cudnn_filename = "#{node['caffe']['cudnn_tarball_name_wo_tgz']}.tgz"
cuda_filename = "#{node['caffe']['CUDA_deb_file']}.deb"

# local files and directories
# creates_lmdb = "#{node['caffe']['lmdb_prefix']}/bin/lmdb"
cuda_local_filename = "/tmp/{#{cuda_filename}}"

# remote filenames
#glog_pre_filename = "#{node['caffe']['glog_pre_deb_file']}.deb"
#glog_filename = "#{node['caffe']['glog_deb_file']}.deb"
#lmdb_filename = "#{node['caffe']['lmdb_deb_file']}.deb"

#glog-0.3.3
# local filenames
#glog_pre_local_filename = "/tmp/libgoogle-glog0v5_0.3.4-0.1+b1_amd64.deb"
#glog_local_filename = "/tmp/libgoogle-glog-dev_0.3.4-0.1+b1_amd64.deb"
#glog_local_filename = "/tmp/"
#lmdb_local_filename = "/tmp/liblmdb-dev_0.9.15-1_amd64.deb"

# linux headers
package "linux-headers-#{node['os_version']}"
# https://forums.aws.amazon.com/thread.jspa?messageID=558414
package "linux-image-#{node['os_version']}"
# http://stackoverflow.com/a/26525293
package "linux-image-extra-#{node['os_version']}"

directory software_dir do
  owner local_user
  group local_group
end

###################################################################
# caffe dependencies that can be installed automagically on 12.04
###################################################################
# package_deps = [
#                 "libprotobuf-dev",
#                 "libleveldb-dev",
#                 "libhdf5-serial-dev",
#                 "protobuf-compiler",
#                 "libjpeg62",
#                 "libfreeimage-dev",
#                 "libatlas-base-dev"]

# package_deps.each do |pkg|
#   package pkg do
#     action :install
#   end
# end

# we have to perform fix-apt-get because
# it produces errors of unknown origin; possible
# due purely to the ~60 or so attempts that have 
# been performed so far.
#
# apparently it's extremely non-trivial to get chef 
# to perform simple actions in the case that apt-get
# fails to install a package propertly. I literally
# can't imagine why this is, but apparently it is so,
# so we're just going to run this *in case* something
# fails to work properly downstream. Lovely.
# bash "fix-apt-get" do
#     code <<-EOH
#         apt-get -f -y install
#     EOH
# end

package_deps = ["libprotobuf-dev",
                "libleveldb-dev",
                "libsnappy-dev",
                "libhdf5-serial-dev",
                "protobuf-compiler"]
package_deps.each do |pkg|
  package pkg do
    action :install
    #notifies :run, 'bash[fix-apt-get]', :immediately
  end
end


package "libboost-all-dev" do
  action :install
  options("--no-install-recommends")
end
###################################################################
# INSTALL GLOG
###################################################################
remote_file "#{software_dir}/#{glog_filename}" do
    source "#{remote_dir}/#{glog_filename}"
    mode 0644
    owner local_user
    group local_group
end
execute "tar -zxf #{glog_filename}" do
    cwd software_dir
    not_if { FileTest.exists? "#{software_dir}/#{node['caffe']['glog_tarball_name_wo_tgz']}" }
    user local_user
    group local_group
end
execute 'google-glog-configure' do
    cwd "#{software_dir}/#{node['caffe']['glog_tarball_name_wo_tgz']}"
    command './configure'
    notifies :run, 'execute[google-glog-make]', :immediately
end
execute 'google-glog-make' do
    cwd "#{software_dir}/#{node['caffe']['glog_tarball_name_wo_tgz']}"
    command "make && make install"
end
###################################################################
# INSTALL LMDB
###################################################################
# now, we're going to adapt libvpx source.rb recipe to install lmdb
git node['caffe']['lmdb_build_dir'] do
    repository node['caffe']['lmdb_git_repository']
    reference node['caffe']['lmdb_git_revision']
    action :sync
end

# I don't think the below is necessary any longer.
# template "#{node['caffe']['build_dir']}/lmdb-compiled_with_flags" do
#     source "compiled_with_flags.erb"
#     owner "root"
#     group "root"
#     mode 0600
#     variables(
#         :compile_flags => node['caffe']['lmdb_compile_flags']
#     )
#     notifies :delete, "file[#{creates_lmdb}]", :immediately
# end

# apparently this just gets executed like, as a thing.
bash "compile_lmdb" do
    cwd "#{node['caffe']['lmdb_build_dir']}/libraries/liblmdb"
    environment 'prefix' => "#{node['caffe']['lmdb_prefix']}"
    code <<-EOH
        make clean && make && make install
    EOH
    #not_if {  ::File.exists?(creates_lmdb) }
end

###################################################################
# INSTALL CUDA
###################################################################
remote_file "#{cuda_local_filename}" do
    source "#{remote_dir}/#{cuda_filename}"
    action :create_if_missing
    notifies :run, 'bash[install-cuda-repo]', :immediately
    owner local_user
    group local_group
end

bash 'install-cuda-repo' do
    action :nothing
    code "dpkg -i #{cuda_local_filename}"
    notifies :run, 'execute[apt-get update]', :immediately
end

execute 'install-cuda' do
    command "apt-get -q -y install --no-install-recommends cuda"
end

remote_file "#{software_dir}/#{cudnn_filename}" do
    source "#{remote_dir}/#{cudnn_filename}"
    mode 0644
    owner local_user
    group local_group
end

execute "tar -zxf #{cudnn_filename}" do
    cwd software_dir
    not_if { FileTest.exists? "#{software_dir}/#{node['caffe']['cudnn_tarball_name_wo_tgz']}" }
    user local_user
    group local_group
end

execute 'cp cudnn.h /usr/local/include' do
    cwd "#{software_dir}/#{node['caffe']['cudnn_tarball_name_wo_tgz']}"
    not_if { FileTest.exists? "/usr/local/include/cudnn.h" }
end

# # below works with cuDNN v1
# [ 'libcudnn_static.a', 'libcudnn.so.6.5.18' ].each do |lib|
#     execute "cp #{lib} /usr/local/lib" do
#         cwd "#{software_dir}/#{node['caffe']['cudnn_tarball_name_wo_tgz']}"
#         not_if { FileTest.exists? "/usr/local/lib/#{lib}" }
#     end
# end

# link "/usr/local/lib/libcudnn.so.6.5" do
#     to "/usr/local/lib/libcudnn.so.6.5.18"
# end

# below works with cuDNN v2 (?)
[ 'libcudnn_static.a', 'libcudnn.so.6.5.45' ].each do |lib|
    execute "cp #{lib} /usr/local/lib" do
        cwd "#{software_dir}/#{node['caffe']['cudnn_tarball_name_wo_tgz']}"
        not_if { FileTest.exists? "/usr/local/lib/#{lib}" }
    end
end

link "/usr/local/lib/libcudnn.so.6.5" do
    to "/usr/local/lib/libcudnn.so.6.5.45"
end

link "/usr/local/lib/libcudnn.so" do
    to "/usr/local/lib/libcudnn.so.6.5"
end

cudnn_installed = true

# set up LD_LIBRARY_PATH
file "/etc/ld.so.conf.d/caffe.conf" do
  owner "root"
  group "root"
  content "/usr/local/cuda-7.0/targets/x86_64-linux/lib"
  notifies :run, 'execute[ldconfig]', :immediately
end

execute 'ldconfig' do
  action :nothing
end

# download caffe and setup initial Makefile.config
git "#{software_dir}/caffe" do
  repository "https://github.com/BVLC/caffe.git"
  revision "66823b59d70097f4ccbe3631b102ef238c08535b" # master as of Sep 3, 2015
  action :sync
  user local_user
  group local_group
end
template "#{software_dir}/caffe/Makefile.config" do
  source "Makefile.config.erb"
  mode 0644
  owner local_user
  group local_group
  variables({
      :cudnn_installed => cudnn_installed
  })
end

execute "this" do
  cwd "#{node[:neon][:home]}"
  user "neon"
  group "neon"
  code <<-EOH
     . enable_env
     make clean BUILD_TYPE=Release && make release
  EOH
end

# install python requirements
execute 'install-python-reqs' do
  cwd "#{software_dir}/caffe/python"
  command "(for req in $(cat requirements.txt); do pip install --no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html $req; done) && touch /home/#{local_user}/.caffe-python-reqs-installed && chown #{local_user}:#{local_group} /home/#{local_user}/.caffe-python-reqs-installed"
  creates "/home/#{local_user}/.caffe-python-reqs-installed"
end

# make caffe!
execute 'build-caffe' do
  cwd "#{software_dir}/caffe"
  command "make all -j8"
  creates "#{software_dir}/caffe/build"
  user local_user
  group local_group
  notifies :run, 'execute[build-caffe-tests]', :immediately
end
execute 'build-caffe-tests' do
  cwd "#{software_dir}/caffe"
  command "make test -j8"
  action :nothing
  user local_user
  group local_group
  notifies :run, 'execute[build-caffe-python]', :immediately
end
execute 'build-caffe-python' do
  cwd "#{software_dir}/caffe"
  command "make pycaffe"
  action :nothing
  user local_user
  group local_group
end

# fix warning message 'libdc1394 error: Failed to initialize libdc1394' when running make runtest
# http://stackoverflow.com/a/26028597
# need to set this on each boot since the /dev links are cleared after shutdown
cron_d 'fix-libdc1394-warning' do
  predefined_value '@reboot'
  command 'ln -s /dev/null /dev/raw1394'
end

# set path
magic_shell_environment 'PATH' do
  value "$PATH:#{software_dir}/caffe/build/tools"
end
magic_shell_environment 'PYTHONPATH' do
  value "$PYTHONPATH:#{software_dir}/caffe/python"
end