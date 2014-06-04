# Grab the latest repo
include_recipe "neon::repo"

# Build the job to run
execute "build stats jar" do
  command "mvn generate-sources package"
  cwd "#{node[:neon][:code_root]}/stats/java"
  user "neon"
end

# Turn on the cron job
cron "stats_manager" do
  action :create
  user "statsmanager"
  hour "1-23/3"
  minute "10"
  mailto "ops@neon-lab.com"
  command "#{node[:neon][:code_root]}/stats/batch_processor.py --mr_jar #{node[:neon][:code_root]}/stats/java/target/neon-stats-1.0-job.jar --utils.monitor.carbon_server #{node[:neon][:carbon_host]} --utils.monitor.carbon_port #{node[:neon][:carbon_port]} --utils.logs.file #{node[:neon][:log_dir]}/stats_manager/stdout.log --utils.logs.do_stderr 0 --master_host_key_file #{node[:neon][:home]}/statsmanager/.ssh/cluster_known_hosts"
end
