# Configure the flume agent that will listen to the logs from the
# stats manager job
node.default[:neon_logs][:flume_streams][:statsmanager_logs] = 
  get_jsonagent_config(node[:neon_logs][:json_http_source_port],
                       "stats_manager")

if node[:opsworks][:activity] == "config" then
  include_recipe "neon_logs::flume_core_config"
else
  include_recipe "neon_logs::flume_core"
end

# Write the configuration file for the statsmanager
template node[:stats_manager][:config] do
  source "statsmanager.conf.erb"
  owner node[:stats_manager][:user]
  group node[:stats_manager][:group]
  mode "0644"
  variables({ 
              :batch_period => node[:stats_manager][:batch_period],
              :cluster_type => node[:stats_manager][:cluster_type],
              :cluster_name => node[:stats_manager][:cluster_name],
              :cluster_ip => node[:stats_manager][:cluster_public_ip],
              :cluster_log_uri => node[:stats_manager][:cluster_log_uri],
              :cluster_subnet_id => node[:stats_manager][:cluster_subnet_id],
              :emr_key => node[:stats_manager][:emr_key],
              :max_task_instances => node[:stats_manager][:max_task_instances],
              :airflow_start_date => node[:stats_manager][:airflow_start_date],
              :notify_email => node[:stats_manager][:notify_email],
              :full_run_input_path => node[:stats_manager][:full_run_input_path],
              :n_core_instances => node[:stats_manager][:n_core_instances],
              :input_path => node[:neon][:input_path],
              :cleaned_output_path => node[:neon][:cleaned_output_path],
              :log_file => node[:stats_manager][:log_file],
              :carbon_host => node[:neon][:carbon_host],
              :carbon_port => node[:neon][:carbon_port],
              :flume_log_port => node[:neon_logs][:json_http_source_port],
            })
end
