require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
# require 'mina/rvm'    # for rvm support. (https://rvm.io)
require 'mina_sidekiq/tasks'

# Basic and Optional settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :user, 'root'          # Username in the server to SSH to.
set :domain, '159.203.165.168'
set :deploy_to, "/root/deploy/rafeek"
set :repository, 'git@github.com:VortexDeveloper/rafeek.git'
set :branch, 'master'
#   set :port, '30000'      # SSH port number.
# set :ssh_options, '-A'
set :forward_agent, true    # SSH forward_agent.

# shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
# set :shared_files, fetch(:shared_files, []).push('database.yml', 'secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0}
  # command %{gem install rails}
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/pids/")
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/log/")
end

desc "Deploys the current version to the server."
task deploy: :environment do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    command %{source ~/.profile}
    invoke :'sidekiq:quiet'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{source ~/.profile}
        # command %{/usr/share/logstash/bin/logstash -f quickstart.conf}
        # command "RAILS_ENV='production' rake db:seed"
        command "chown -R www-data:www-data /root/deploy/rafeek/current/"
        command "chown -R www-data:www-data /root/deploy/rafeek/current/public/"
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        command %{touch tmp/sidekiq.pid}
      end
      command %{source ~/.profile}
      command %{echo $DATABASE_PASSWORD }
      invoke :'sidekiq:restart'
    end

    invoke :'deploy:cleanup'
  end
end
