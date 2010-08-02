
default_run_options[:pty] = true
set :user, 'buildmaster'
set :use_sudo, true
set :ssh_options, { :port => 30000, :forward_agent => true }

set :application, 'propsify'
set :domain, 'propsify.com'
set :repository, 'git@bayanihan.unfuddle.com:bayanihan/md2.git'
set :deploy_to, "/opt/apps/#{application}"
set :deploy_via, :remote_cache
set :scm, :git
set :branch, 'master'
set :git_shallow_clone, 1
set :scm_verbose, true

server domain, :app, :web
role :db, domain, :primary => true

task :after_update_code, :roles => :app do
  db.symlink
  deploy.rebuild_gems
  sphinx.symlink
  sphinx.configure
  crontab.install
end

namespace :db do

  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config"
    run "ln -nfs #{shared_path}/config/twitter.yml  #{release_path}/config"
  end

end

namespace :deploy do

  desc 'Restarting mod_rails with restart.txt'
  task :restart, :roles => :app, :except => { :no_release => true } do
    sphinx.restart
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do; end
  end

  task :rebuild_gems do
    run "rake -f #{release_path}/Rakefile gems:build RAILS_ENV=production"
  end

end

namespace :sphinx do

  task :symlink, :roles => :app do
    #run "ln -nfs #{shared_path}/config/sphinx.yml #{release_path}/config"
    run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/"
  end

  task :configure, :roles => :app do
    run "cd #{release_path} && rake thinking_sphinx:configure RAILS_ENV=production"
  end

  desc 'Start the sphinx server'
  task :start, :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:start RAILS_ENV=production"
  end

  desc 'Stop the sphinx server'
  task :stop , :roles => :app do
    run "cd #{current_path} && rake thinking_sphinx:stop RAILS_ENV=production"
  end

  desc 'Restart the sphinx server'
  task :restart, :roles => :app do
    stop
    start
  end 

end

namespace :crontab do

  set :crontab_template, "#{current_path}/config/crontab.erb"
  set :crontab_file, "#{current_path}/config/crontab"

  task :install do
    render_crontab_template
    run "crontab -r; crontab #{crontab_file}"
  end

  def render_crontab_template
    require 'erb'
    temp = 'template.tmp'
    get crontab_template, temp
    buffer = ERB.new(File.read(temp)).result(binding)
    put buffer, crontab_file
    File.unlink temp
  end

  def rails_env
    fetch(:rails_env, 'production')
  end

end
