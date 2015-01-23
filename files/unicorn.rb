# bundle exec unicorn_rails -c config/unicorn.rb -E production -D -l 127.0.0.1:3000
worker_processes 2

rails_root = File.expand_path('../../',  __FILE__)

listen "#{rails_root}/tmp/sockets/unicorn.sock"
pid    "#{rails_root}/tmp/pids/unicorn.pid"

stderr_path "#{rails_root}/log/unicorn_error.log"
stdout_path "#{rails_root}/log/unicorn.log"

preload_app false
