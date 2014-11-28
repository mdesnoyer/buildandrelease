
include_recipe "trackserver::collector_config"

# Specify which repos will be installed
node.default[:neon][:repos]["tracklog_collector"] = true
node.default[:neon][:repos]["core"] = false
node.default[:neon][:repos]["track_server"] = false
 
node[:deploy].each do |app_name, deploy|
  if app_name != "tracklog_collector" then
    next
  end

  repo_path = get_repo_path("tracklog_collector")

  Chef::Log.info("Deploying app #{app_name} using code path #{repo_path}")

  # install hbase libraries
  include_recipe "hadoop::hbase"

  # install maven
  package "maven" do
    :install
  end
  directory "#{node[:neon][:home]}/.m2" do
    owner "neon"
    group "neon"
    action :create
    mode "0755"
    recursive true
  end
    
  # Install the neon code
  include_recipe "neon::repo"

  # Build the java code
  app_built = "#{repo_path}/BUILD_DONE"
  file app_built do
    user "neon"
    group "neon"
    action :nothing
    subscribes :delete, "git[#{repo_path}]", :immediately
  end
  execute "compile_#{app_name}" do
    command "mvn generate-sources package"
    cwd "#{repo_path}/flume"
    user "neon"
    group "neon"
    not_if {  ::File.exists?(app_built) }
    notifies :create, "file[#{app_built}]"
  end

  # Install the flume plugin
  plugin_dir = "/usr/lib/flume-ng/plugins.d/neon/"
  directory "#{plugin_dir}/lib" do
    owner "root"
    group "root"
    action :create
    recursive true
    mode "0755"
  end
  jars = ["flume/target/neon-hbase-serializer-1.0-jar-with-dependencies.jar"]
  for jar_path in jars do
    jar_name = ::File.basename(jar_path)
    remote_file "#{plugin_dir}/lib/#{jar_name}" do
      source "file://#{repo_path}/#{jar_path}"
      notifies :restart, "service[#{node[:neon_logs][:flume_service_name]}]", :delayed
    end
  end
    
  # Install flume
  include_recipe "neon_logs::flume_core"

  if ['undeploy'].include? node[:opsworks][:activity] then
    service node[:neon_logs][:flume_service_name] do
    action :stop
  end
end
