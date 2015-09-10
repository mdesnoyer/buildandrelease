#
# Cookbook Name:: caffe
# Recipe:: default
#
# Copyright (c) 2015 Neon Labs, All Rights Reserved.

include_recipe "neon::default"
include_recipe "yasm::source"
include_recipe "build-essential"
include_recipe "git"
include_recipe "neon::full_py_repo"


software_dir = node[:caffe][:software_dir]
remote_dir = node[:caffe][:remote_dir]
local_user = node[:caffe][:local_user]
local_group = node[:caffe][:local_group]
glog_filename = "#{node["caffe"]["glog_tarball_name_wo_tgz"]}.tar.gz"
cudnn_filename = "#{node['caffe']['cudnn_tarball_name_wo_tgz']}.tgz"
creates_lmdb = "#{node['caffe']['lmdb_prefix']}/bin/lmdb"

# remote filenames
#cuda_filename = "#{node['caffe']['CUDA_deb_file']}.deb"
#glog_pre_filename = "#{node['caffe']['glog_pre_deb_file']}.deb"
#glog_filename = "#{node['caffe']['glog_deb_file']}.deb"
#lmdb_filename = "#{node['caffe']['lmdb_deb_file']}.deb"

#glog-0.3.3
# local filenames
#cuda_local_filename = "/tmp/cuda-repo-ubuntu1204-7-0-local_7.0-28_amd64.deb"
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

# caffe dependencies
package_deps = [
                "libprotobuf-dev",
                "libleveldb-dev",
                "libhdf5-serial-dev",
                "protobuf-compiler",
                "libjpeg62",
                "libfreeimage-dev",
                "libatlas-base-dev"]

package_deps.each do |pkg|
  package pkg do
    action :install
  end
end

# let's attempt to install glog, in the same vein as cudnn
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

# now, we're going to adapt libvpx source.rb recipe to install lmdb
file "#{creates_lmdb}" do
    action :nothing
    subscribes :delete, "bash[compile_yasm]", :immediately
end

git node['caffe']['lmdb_build_dir'] do
    repository node['caffe']['lmdb_git_repository']
    reference node['caffe']['lmdb_git_revision']
    action :sync
    notifies :delete, "file[#{creates_lmdb}]", :immediately
end

template "#{node['caffe']['build_dir']}/lmdb-compiled_with_flags" do
    source "compiled_with_flags.erb"
    owner "root"
    group "root"
    mode 0600
    variables(
        :compile_flags => node['caffe']['lmdb_compile_flags']
    )
    notifies :delete, "file[#{creates_lmdb}]", :immediately
end

# apparently this just gets executed like, as a thing.
bash "compile_lmdb" do
    cwd node['caffe']['lmdb_build_dir']
    # code <<-EOH
    #     make clean && make && make install
    # EOH
    code <<-EOH
        make && make install
    EOH
    not_if {  ::File.exists?(creates_lmdb) }
end

# install CUDA

remote_file "#{cuda_local_filename}" do
  source "#{cuda_filename}"
  mode 0644
end

dpkg_package "cuda" do
  source "#{cuda_local_filename}"
  action :install
end

remote_file "#{cuda_local_filename}" do
    source "#{cuda_filename}"
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

# ------------------ legit stuff -------------------- #
# cookbook_file "#{software_dir}/#{cudnn_filename}" do
#     source "cudnn-tarball/#{cudnn_filename}"
#     mode 0644
#     owner local_user
#     group local_group
# end
# execute "tar -zxf #{cudnn_filename}" do
#     cwd software_dir
#     not_if { FileTest.exists? "#{software_dir}/#{node['caffe']['cudnn_tarball_name_wo_tgz']}" }
#     user local_user
#     group local_group
# end
# execute 'cp cudnn.h /usr/local/include' do
#     cwd "#{software_dir}/#{node['caffe']['cudnn_tarball_name_wo_tgz']}"
#     not_if { FileTest.exists? "/usr/local/include/cudnn.h" }
# end
# [ 'libcudnn_static.a', 'libcudnn.so.6.5.18' ].each do |lib|
#     execute "cp #{lib} /usr/local/lib" do
#         cwd "#{software_dir}/#{node['caffe']['cudnn_tarball_name_wo_tgz']}"
#         not_if { FileTest.exists? "/usr/local/lib/#{lib}" }
#     end
# end
# link "/usr/local/lib/libcudnn.so.6.5" do
#     to "/usr/local/lib/libcudnn.so.6.5.18"
# end
# link "/usr/local/lib/libcudnn.so" do
#     to "/usr/local/lib/libcudnn.so.6.5"
# end
# cudnn_installed = true

# # set up LD_LIBRARY_PATH
# file "/etc/ld.so.conf.d/caffe.conf" do
#   owner "root"
#   group "root"
#   content "/usr/local/cuda-7.0/targets/x86_64-linux/lib"
#   notifies :run, 'execute[ldconfig]', :immediately
# end
# execute 'ldconfig' do
#   action :nothing
# end

# # download caffe and setup initial Makefile.config
# git "#{software_dir}" do
#   repository "https://github.com/BVLC/caffe.git"
#   revision "66823b59d70097f4ccbe3631b102ef238c08535b" # master as of Sep 3, 2015
#   action :sync
#   user local_user
#   group local_group
# end
# template "#{software_dir}/Makefile.config" do
#   source "Makefile.config.erb"
#   mode 0644
#   owner local_user
#   group local_group
#   variables({
#       :cudnn_installed => cudnn_installed
#   })
# end

# # install python requirements
# execute 'install-python-reqs' do
#   cwd "#{software_dir}/python"
#   command "(for req in $(cat requirements.txt); do pip install $req; done) && touch /home/#{local_user}/.caffe-python-reqs-installed && chown #{local_user}:#{local_group} /home/#{local_user}/.caffe-python-reqs-installed"
#   creates "/home/#{local_user}/.caffe-python-reqs-installed"
# end

# # make caffe!
# execute 'build-caffe' do
#   cwd "#{software_dir}"
#   command "make all -j8"
#   creates "#{software_dir}/build"
#   user local_user
#   group local_group
#   notifies :run, 'execute[build-caffe-tests]', :immediately
# end
# execute 'build-caffe-tests' do
#   cwd "#{software_dir}"
#   command "make test -j8"
#   action :nothing
#   user local_user
#   group local_group
#   notifies :run, 'execute[build-caffe-python]', :immediately
# end
# execute 'build-caffe-python' do
#   cwd "#{software_dir}"
#   command "make pycaffe"
#   action :nothing
#   user local_user
#   group local_group
# end

# # # fix warning message 'libdc1394 error: Failed to initialize libdc1394' when running make runtest
# # # http://stackoverflow.com/a/26028597
# # # need to set this on each boot since the /dev links are cleared after shutdown
# # cron_d 'fix-libdc1394-warning' do
# #   predefined_value '@reboot'
# #   command 'ln -s /dev/null /dev/raw1394'
# # end

# # set path
# magic_shell_environment 'PATH' do
#   value "$PATH:#{software_dir}/build/tools"
# end
# magic_shell_environment 'PYTHONPATH' do
#   value "$PYTHONPATH:#{software_dir}/python"
# end

# install_interactive = node[:caffe][:interactive]

# if install_interactive
#     execute "pip install ipython"
# end