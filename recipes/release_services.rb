bash "Start Services" do
  user "root"
  code <<-EOH
  echo "setup monitoring config"
  echo "start services"
  echo "restart monit with new config"
  EOH
end
