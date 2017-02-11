# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, ''
set :repo_url, ''

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, ''

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/application.yml config/initializers/dragonfly.rb}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{tmp/pids tmp/cache public/system public/javascripts}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# Give resque access to Rails environment
set :resque_environment_task, true

set :default_env, {
  PATH: "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH",
  RBENV_ROOT: '~/.rbenv',
  RBENV_VERSION: '2.3.0'
}

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
      with rails_env: :production do
        within release_path do
          execute :rake, 'websocket:restart'
          execute :rake, 'i18n:js:export'
        end
      end
    end
  end

  after :publishing, :restart

  after :restart, "resque:restart"

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :seed do
  desc "Upload post categories."
  task :upload_post_categories do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "post_categories:create_parents"
          execute :rake, "post_categories:upload"
        end
      end
    end
  end
end

namespace :authentication do
  desc "Reset all passwords."
  task :reset_passwords do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "passwords:create"
        end
      end
    end
  end
end