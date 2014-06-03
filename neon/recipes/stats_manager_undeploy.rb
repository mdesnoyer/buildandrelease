# Turn off the cron job
cron "stats_manager" do
  action :delete
end
