require 'bundler/capistrano'
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"
set :application, "FinforeAdmin"
set :domain, "admin.fastnd.com"
set :repository,  "git@github.com:FinforeOrg/fastnd_administrator.git"
set :scm, :git
set :branch, "master"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, "/home/staging/fastnd_admin"

# since we're using assets pipelining feature of rails 3.2
# we don't need this, turning this to true will makes capistrano throw some warning
# regarding missing asset folders
set :normalize_asset_timestamps, false
set :port, 9847
set :user, "staging"
set :use_sudo, true
set :keep_releases, 10
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

role :web, domain                   # Your HTTP server, Apache/etc
role :app, domain                   # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :symlink_shared_assets do
    run "rm #{release_path}/config/mongoid.yml"
    run "rm #{release_path}/config/deploy.rb"
    run "rm -rf #{release_path}/tmp/"
    run "rm -rf #{release_path}/log/"
    run "ln -ns #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
    run "ln -ns #{shared_path}/config/deploy.rb #{release_path}/config/deploy.rb"
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    run "ln -nfs #{shared_path}/log #{release_path}/log"
    run "ln -nfs #{shared_path}/public/assets #{release_path}/public/assets"
    run "ln -nfs #{shared_path}/assets #{release_path}/assets"
  end
  task :create_db_index do
    run "cd #{release_path} && rake db:mongoid:create_indexes RAILS_ENV=production"
  end
end

after "deploy:update_code", "deploy:symlink_shared_assets"
#after "deploy:finalize_update", "deploy:create_db_index"


