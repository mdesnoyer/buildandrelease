# Installs the full python repo and all of the dependencies in the
# requirements.txt file.

# Install the repo
include_recipe "neon::repo"

apps = [nil]
if node[:opsworks][:activity] == 'deploy' then
  node[:deploy].each do |app, data|
    apps << app
  end
end

# Install packages that are needed
package_deps = [
                "libfreetype6-dev",
                "libatlas-base-dev",
                "libyaml-0-2",
                "libcurl4-openssl-dev",
                "libboost1.46-dev",
                "libboost1.46-dbg",
                "fftw3-dev"
               ]
package_deps.each do |pkg|
  package pkg do
    action :install
  end
end

# Install opencv
include_recipe "neon-opencv"

# Install gflags
if platform?("ubuntu") then
  ['libgflags-dev', 'libgflags0'].each do | pkg |
    cur_file = "#{pkg}_#{node[:gflags][:version]}_#{Chef::Extensions::Platform.arch()}.deb"
    remote_file "#{Chef::Config[:file_cache_path]}/#{cur_file}" do
      source "#{default[:gflags][:package][:url_base]}#{cur_file}"
    end
    package pkg do
      action :install
      source "#{Chef::Config[:file_cache_path]}/#{cur_file}"
    end
  end
else
  include_recipe "gflags"
end

# Install perftools and libunwind
code_path = get_repo_path(nil)
directory "#{Chef::Config[:file_cache_path]}/pprof" do
    :create
end
bash "install_libunwind" do
    cwd "#{Chef::Config[:file_cache_path]}/pprof"
    code <<-EOH
         tar -xzf #{code_path}/externalLibs/libunwind-0.99-beta.tar.gz
         cd libunwind-0.99-beta
         ./configure CFLAGS=-U_FORTIFY_SOURCE LDFLAGS=-L`pwd`/src/.libs
         make -j#{node[:cpu][:total]} install
    EOH
    creates "/usr/include/libunwind.h"
end

bash "install_perftools" do
    cwd "#{Chef::Config[:file_cache_path]}/pprof"
    code <<-EOH
         tar -xzf #{code_path}/externalLibs/gperftools-2.1.tar.gz
         cd gperftools-2.1
         ./configure
         make -j#{node[:cpu][:total]} install
    EOH
    creates "/usr/local/bin/pprof"
end
    

# Install all the python dependencies
apps.each do |app|
  code_path = get_repo_path(app)
  execute "py_pre_reqs[#{app}]" do
    command "pip install --no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html -r #{code_path}/pre_requirements.txt"
    action :run
  end

  execute "py_install_reqs[#{app}]" do
    command "pip install --no-index --find-links http://s3-us-west-1.amazonaws.com/neon-dependencies/index.html -r #{code_path}/requirements.txt"
    action :run
  end
end

package "python-nose" do
  :install
end
