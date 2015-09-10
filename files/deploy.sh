#!/bin/sh
#cwd=$(cd $(dirname $0);pwd)
set -ex

# sudo cp -r config/nginx/ /etc/nginx/
# rake db:create RAILS_ENV=production
# rake db:migrate RAILS_ENV=production

if [ $# -ne 1 ]; then
  SERVER='<%= app_name %>'
else
  SERVER=$1
fi

APP='<%= app_name %>'

echo "\033[0;32mgit branch\033[0;39m"
DATE=`date +%Y%m%d-%H%I%S`

echo "\033[0;32mrsync\033[0;39m"
rsync -avzS --delete --exclude ".git/" --exclude "log/" --exclude "tmp/" -e ssh ~/$APP/ $SERVER:/home/webuser/$APP/

echo "\033[0;32mdb backup\033[0;39m"
ssh $SERVER "/usr/bin/mysqldump -uroot ${APP}_production > /home/webuser/${APP}_production.${SERVER}"
scp $SERVER:/home/webuser/${APP}_production.${SERVER} /home/webuser/${APP}/tmp/${APP}_production.${SERVER}

echo "\033[0;32mrun server\033[0;39m"
ssh $SERVER "cd /home/webuser/$APP/ && /home/webuser/.rbenv/shims/bundle"
ssh $SERVER "cd /home/webuser/$APP/ && /home/webuser/.rbenv/shims/bundle exec rake assets:precompile RAILS_ENV=production"
ssh $SERVER "/home/webuser/$APP/bin/kill_unicorn.sh $APP"
ssh $SERVER "cd /home/webuser/$APP/ && /home/webuser/.rbenv/shims/bundle exec unicorn_rails -c ~/$APP/config/unicorn.rb -E production -D -l 127.0.0.1:3000"
ssh $SERVER "ps aux | grep rails"
ssh $SERVER "ps aux | grep nginx"

echo "\033[0;32mdone\033[0;39m"
echo "$ sudo service nginx restart"
echo "See: http://<%= app_name %>/"
