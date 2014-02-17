. ./env.sh
cat cfg/nginx.conf | sed "s/PGDATABASE/$PGDATABASE/g" | sed "s/PGUSER/$PGUSER/g" | sed "s/PGPASSWORD/$PGPASSWORD/g" | sed "s/WEBROOT/$WEBROOT/g" | sed "s/NGXPORT/$NGXPORT/g" > bin/nginx/conf/nginx.conf

bin/nginx/sbin/nginx -s stop || echo 'not running'
echo 'Starting nginx...'
bin/nginx/sbin/nginx
echo 'netstat'
netstat -pant | grep 5555
echo 'error log'
tail -n 30 bin/nginx/logs/error.log
