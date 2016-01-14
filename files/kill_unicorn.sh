if [ -e ~/$1/tmp/pids/unicorn.pid ]; then
  kill `cat ~/$1/tmp/pids/unicorn.pid`
fi
