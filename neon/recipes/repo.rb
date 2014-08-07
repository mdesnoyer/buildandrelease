# This recipe gets the most recent version of the repository

include_recipe "neon::default"

# Create the base directory for the repo copies
directory "#{node[:neon][:code_root]}" do
  action :create
  owner "neon"
  group "neon"
  mode "1755"
  recursive true
end

# Create the ssh directory
directory "#{node[:neon][:home]}/.ssh" do
  owner "neon"
  group "neon"
  action :create
  mode "0700"
end

# Cycle through all the repos to install.
node[:neon][:repos].each do |app_name, do_deploy|
  if not do_deploy then
    # This app was turned off
    next
  end

  valid_name = app_name.downcase.tr(' ', '')
  if not node[:deploy][app_name].nil? then
    scm_data = node[:deploy][app_name][:scm]
    data = {
      :name => valid_name,
      :app_name => app_name,
      :code_folder => get_repo_path(app_name),
      :repo_key => scm_data[:ssh_key] || node[:neon][:repo_key],
      :repo_url => scm_data[:repository] || node[:neon][:repo_url],
      :revision => scm_data[:revision] || node[:neon][:code_revision]
    }
  elsif app_name == "core" then
    data = {
      :name => "core",
      :app_name => nil,
      :code_folder => get_repo_path(nil),
      :repo_key => node[:neon][:repo_key],
      :repo_url => node[:neon][:repo_url],
      :revision => node[:neon][:code_revision]
    }
  else
    Chef::Log.warn("Asked for a deploy of app #{app_name}, but it's not known. Ignoring")
    next
  end

  # Create the code directory
  directory "#{data[:code_folder]}" do
    action :create
    owner "neon"
    group "neon"
    mode "1755"
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
  git data[:code_folder] do
    repository data[:repo_url]
    revision data[:revision]
    enable_submodules true
    action :sync
    user "neon"
    group "neon"
    ssh_wrapper "#{node[:neon][:code_root]}/#{data[:name]}-wrap-ssh4git.sh"
  end

end
