include_attribute "neon::default"

# ssh key to control Elastic Map Reduce clusters
default[:stats_manager][:emr_key] = "s3://neon-keys/emr-runner.pem"
