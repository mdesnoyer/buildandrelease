include_attribute "redis"

# Redis configuration
default[:redis][:version] = "2.8.19"
default[:redis][:source_checksum] = "29bb08abfc3d392b2f0c3e7f48ec46dd09ab1023f9a5575fc2a93546f4ca5145"
default[:redis][:db_dir] = '/mnt/redis'
default[:redis][:bind_address] = node[:opsworks][:instance][:private_ip]
default[:redis][:log_file] = "#{node[:redis][:db_dir]}/redis.log"
default[:redis][:appendonly] = 'yes'
default[:redis][:notify_keyspace_events] = 'Kgsz$'


# Master/slave options
default[:cmsdb][:is_slave] = false
default[:cmsdb][:master_layer] = "redis"
default[:cmsdb][:master_fallback_host] = "redis1"

# Configuration for the backup cron
default[:cmsdb][:backup_s3_bucket] = 'neon-db-backup'
default[:cmsdb][:backup_log] = '/mnt/neon/redis_backup.log'
