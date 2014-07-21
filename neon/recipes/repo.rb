# This recipe gets the most recent version of the repository
# TODO(mdesnoyer): Use the actual deploy data to install the repo

include_recipe "neon::default"

# If this is a deploy, then take the repo information from the OpsWorks
# deploy data
deploy_apps = []
if node[:opsworks][:activity] == 'deploy' then
  node[:deploy].each do |app_name, data|
    valid_name = app_name.downcase.tr(' ', '')
    deploy_apps << { 
      :name => valid_name,
      :code_folder => data[:document_root] || valid_name,
      :repo_key => data[:scm][:ssh_key] || node[:neon][:repo_key],
      :repo_url => data[:scm][:repository] || node[:neon][:repo_url],
      :revision => data[:scm][:revision] || node[:neon][:code_revision]
    }
  end
else
  deploy_apps << {
    :name => "core",
    :code_folder => "core",
    :repo_key => node[:neon][:repo_key],
    :repo_url => node[:neon][:repo_url],
    :revision => node[:neon][:code_revision]
  }
end

# Create the ssh directory
directory "#{node[:neon][:home]}/.ssh" do
  owner "neon"
  group "neon"
  action :create
  mode "0700"
end

deploy_apps.each do |data|

  # Create the code directory
  directory "#{node[:neon][:code_root]}/#{data[:code_folder]}" do
    action :create
    owner "neon"
    group "neon"
    mode "1755"
    recursive true
  end

  # Install the ssh deploy key to get the repository
  if data[:repo_key].start_with?("s3://") then
    # The key is on s3, so go get it
    s3_file "#{node[:neon][:home]}/.ssh/#{data[:name]}.pem" do
      source data[:repo_key]
      owner "neon"
      group "neon"
      action :create
      mode "0600"
    end
  else
    # The key is in the variable, so write it to a file
    file "#{node[:neon][:home]}/.ssh/#{data[:name]}.pem" do
      content data[:repo_key]
      owner "neon"
      group "neon"
      action :create
      mode "0600"
    end
  end

  template "#{node[:neon][:code_root]}/#{data[:name]}-wrap-ssh4git.sh" do
    owner "neon"
    group "neon"
    source "wrap-ssh4git.sh.erb"
    mode "0755"
    variables({:ssh_key => "#{node[:neon][:home]}/.ssh/#{data[:name]}.pem"})
  end

  # Get the code repository
  git "#{node[:neon][:code_root]}/#{data[:code_folder]}" do
    repository data[:repo_url]
    revision data[:code_revision]
    enable_submodules true
    action :sync
    user "neon"
    group "neon"
    ssh_wrapper "#{node[:neon][:code_root]}/#{data[:name]}-wrap-ssh4git.sh"
  end

end
