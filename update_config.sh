cp cfg/nginx.conf bin/nginx/conf/
bin/nginx/sbin/nginx -s stop || echo 'not running'
echo 'Starting nginx...'
bin/nginx/sbin/nginx
echo 'netstat'
netstat -pant | grep 5555
echo 'error log'
tail bin/nginx/logs/error.log
