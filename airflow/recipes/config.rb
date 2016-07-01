# Airflow configuration
template node[:airflow][:config_file] do
  source "airflow.cfg.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :airflow_home => node[:airflow][:home],
              :dags_folder => node[:airflow][:dags_folder],
              :airflow_logs => node[:airflow][:airflow_logs],
              :db_user => node[:airflow][:db_user],
              :db_password => node[:airflow][:db_password],
              :db_host => node[:airflow][:db_host],
              :db_port => node[:airflow][:db_port],
              :db_name => node[:airflow][:db_name],
              :webserver_host => node[:airflow][:webserver_host],
              :webserver_port => node[:airflow][:webserver_port],
              :smtp_user => node[:airflow][:smtp_user],
              :smtp_password => node[:airflow][:smtp_password],
              :smtp_host => node[:airflow][:smtp_host],
              :smtp_port => node[:airflow][:smtp_port],
              :smtp_from => node[:airflow][:smtp_from],
              :parallelism => node[:airflow][:parallelism],
              :non_pooled_task_slot_count => node[:airflow][:non_pooled_task_slot_count],
              :fernet_key => node[:airflow][:fernet_key],
              :expose_config => node[:airflow][:expose_config],
              :workers => node[:airflow][:workers],
              :celeryd_concurrency => node[:airflow][:celeryd_concurrency],
              :flower_port => node[:airflow][:flower_port],
              :task_memory => node[:airflow][:task_memory],
              :extra_params => node[:airflow][:params]
            })
end

# Setup login shell environment for users
template "/etc/profile.d/airflow.sh" do
  source "airflow.sh.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :airflow_home => node[:airflow][:home]
            })
end

# Airflow Webserver service
template "/etc/init/airflow-web.conf" do
  source "airflow-web.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :user => node[:airflow][:user],
              :group => node[:airflow][:group],
              :airflow_home => node[:airflow][:home],
              :webserver_port => node[:airflow][:webserver_port]
            })
end

# Airflow Scheduler service
template "/etc/init/airflow-scheduler.conf" do
  source "airflow-scheduler.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :user => node[:airflow][:user],
              :group => node[:airflow][:group],
              :airflow_home => node[:airflow][:home]
            })
end

# Airflow Worker (Celery-based)
template "/etc/init/airflow-worker.conf" do
  source "airflow-worker.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables({
              :user => node[:airflow][:user],
              :group => node[:airflow][:group],
              :airflow_home => node[:airflow][:home]
            })
end
