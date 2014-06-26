#Get the latest commit from git --> Make test & release --> setup monitoring & init scripts --> start services --> start monit
bash "Build and test Code" do
  user "root"
  code <<-EOH
  echo "start building the code" 
  cd /opt/neon/
  git stash
  git clean -f
  git pull git@github.com:neon-lab/neon-codebase.git
  source enable_env
  make clean
  ./run_tests.sh Debug
  make release
  source disable_env
  EOH
end
