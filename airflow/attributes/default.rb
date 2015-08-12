include_attribute "neon"
include_attribute "neon::repo"
include_attribute "neon_logs::default"

default[:airflow][:airflow_home] = "#{node[:neon][:code_root]}/stats/airflow"
default[:airflow][:airflow_logs] = "#{node[:neon][:log_dir]}/airflow"

default[:airflow][:user] = 'airflow'
default[:airflow][:group] = 'airflow'

default[:airflow][:webserver_port] = 8080

# MySQL RDS for Airflow state
default[:airflow][:db_user] = "airflow"
default[:airflow][:db_password] = "airflow"
default[:airflow][:db_host] = "localhost"
default[:airflow][:db_port] = 3306
default[:airflow][:db_name] = "airflow"
