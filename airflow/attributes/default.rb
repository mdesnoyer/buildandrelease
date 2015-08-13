include_attribute "neon"
include_attribute "neon::repo"
include_attribute "neon_logs::default"

# Neon's Airflow configuration and DAG files are in stats/airflow
#default[:airflow][:airflow_home] = "#{repo_path}/stats/airflow"
default[:airflow][:airflow_logs] = "#{node[:neon][:log_dir]}/airflow"

# Run as the Neon user
default[:airflow][:user] = 'statsmanager'
default[:airflow][:group] = 'statsmanager'

# Webserver
default[:airflow][:webserver_host] = node[:hostname]
default[:airflow][:webserver_port] = 8080

# MySQL RDS for Airflow state
default[:airflow][:db_user] = "airflow"
default[:airflow][:db_password] = "airflow"
default[:airflow][:db_host] = "localhost"
default[:airflow][:db_port] = 3306
default[:airflow][:db_name] = "airflow"

# SMTP Mail for task failures and SLA violations
default[:airflow][:smtp_user] = "AKIAJZLS2HPKH33MY5RA"
default[:airflow][:smtp_password] = "AtpM77bc0orv6qT+e0G3Hrazz3cs1gn9Kk9TWZF+A19j"
default[:airflow][:smtp_host] = "email-smtp.us-east-1.amazonaws.com"
default[:airflow][:smtp_port] = 25
default[:airflow][:smtp_from] = "ops@neon-lab.com"

default[:airflow][:version] = "1.3.0"
