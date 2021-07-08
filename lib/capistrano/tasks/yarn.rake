namespace :yarn do
  task :install do
    on release_roles :all do
      within release_path do
        execute "cd #{release_path} && yarn install"
      end
    end
  end
  task :build do
     on release_roles :all do
        within release_path do
          execute "cd #{release_path} && yarn build"
        end
      end
  end
end