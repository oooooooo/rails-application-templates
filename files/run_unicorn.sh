APP=$1
cd $HOME/$APP/ && $HOME/.rbenv/shims/bundle exec unicorn_rails -c $HOME/$APP/config/unicorn.rb -E production -D -l 127.0.0.1:3000
