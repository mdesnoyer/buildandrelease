include_attribute "neon"
include_attribute "neon::repo"
include_attribute "neon_logs::default"
include_attribute "airflow"

# ssh key to control Elastic Map Reduce clusters
default[:stats_manager][:emr_key_bucket] = "neon-keys"
default[:stats_manager][:emr_key_path] = "emr-runner.pem"

# Install the stats manager repo
default[:neon][:repos]["stats_manager"] = true

default[:stats_manager][:user] = "statsmanager"
default[:stats_manager][:group] = "statsmanager"

# Locations of various files
default[:stats_manager][:log_dir] = "#{node[:neon][:log_dir]}/statsmanager"
default[:stats_manager][:config] = "#{node[:neon][:config_dir]}/statsmanager.conf"
default[:stats_manager][:log_file] = "#{node[:stats_manager][:log_dir]}/statsmanager.log"
default[:stats_manager][:cluster_log_file] = "#{node[:stats_manager][:log_dir]}/cluster_manager.log"

# Pramaters for the process
default[:stats_manager][:clicklog_period] = 3 # In hours
default[:stats_manager][:cluster_name] = "#{node[:opsworks][:stack][:name]} (Video Events)"
default[:stats_manager][:cluster_type] = "video_click_stats"
default[:stats_manager][:cluster_public_ip] = "54.210.126.245" # Production US-East
default[:stats_manager][:cluster_subnet_ids] = "subnet-e7be7f90,subnet-abf214f2"
default[:stats_manager][:cluster_log_uri] = "s3://neon-cluster-logs/"
default[:stats_manager][:max_task_instances] = 30
default[:stats_manager][:master_instance_type] = 'r3.2xlarge'
default[:stats_manager][:airflow_rebase_date] = '2016-08-19'
default[:stats_manager][:quiet_period] = 30
default[:stats_manager][:mr_jar] = "neon-stats-1.0-job.jar"
default[:stats_manager][:input_path] = "s3://neon-tracker-logs-v2/v2.3"
default[:stats_manager][:full_run_input_path] = "/*/*/*/*/*"
default[:stats_manager][:staging_path] = "s3://neon-tracker-logs-v2/airflow/staging"
default[:stats_manager][:cleaned_output_path] = "s3://neon-tracker-logs-v2/airflow/cleaned"
default[:stats_manager][:cc_cleaned_path] = "s3://neon-tracker-logs-v2/airflow/cc_cleaned"
default[:stats_manager][:yarn_max_memory_allocation] = 32000
default[:stats_manager][:parquet_memory] = 22000
default[:stats_manager][:heap_size] = 12000
default[:stats_manager][:cleaning_mr_memory] = 2048
default[:stats_manager][:notify_email] = 'ops@neon-lab.com'
default[:stats_manager][:n_core_instances] = 15


# Parameters for airflow
default[:airflow][:user] = node[:stats_manager][:user]
default[:airflow][:group] = node[:stats_manager][:group]
default[:airflow][:home] = "#{node[:neon][:config_dir]}/airflow"
default[:airflow][:config_file] = "#{node[:airflow][:home]}/airflow.cfg"
default[:airflow][:airflow_logs] = "#{node[:stats_manager][:log_dir]}/airflow"
default[:airflow][:dags_folder] = "/opt/neon/neon-codebase/statsmanager"
default[:airflow][:db_user] = node[:deploy][:stats_manager][:database][:username]
default[:airflow][:db_password] = node[:deploy][:stats_manager][:database][:password]
default[:airflow][:db_port] = node[:deploy][:stats_manager][:database][:port]
default[:airflow][:db_host] = node[:deploy][:stats_manager][:database][:host]
default[:airflow][:db_name] = node[:deploy][:stats_manager][:database][:database]
# TODO: set the sql parameters to hold the state
default[:airflow][:smtp_host] = "email-smtp.us-east-1.amazonaws.com"
default[:airflow][:smtp_from] = "airflow@neon-lab.com"
default[:airflow][:params][:neon][:config_file] = node[:stats_manager][:config]


