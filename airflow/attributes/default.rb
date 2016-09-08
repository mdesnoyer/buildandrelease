default[:airflow][:home] = "/home/airflow"
default[:airflow][:dags_folder] = "/tmp"
default[:airflow][:airflow_logs] = "/var/log/airflow"
default[:airflow][:config_file] = "#{node[:airflow][:home]}/airflow.cfg"

# User to run airflow with
default[:airflow][:user] = 'airflow'
default[:airflow][:group] = 'airflow'

# Extra configuration parameters that will be written to the airflow
# ini. It is a nested dictionary so
# node[:airflow][:params][:section][:key] = 'value' will generate:
#
# [section]
# key = value
default[:airflow][:params] = {}

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
default[:airflow][:smtp_host] = "some_host"
default[:airflow][:smtp_port] = 25
default[:airflow][:smtp_from] = "airflow@neon-lab.com"

# Airflow version to install
default[:airflow][:version] = "1.7.1.3"
