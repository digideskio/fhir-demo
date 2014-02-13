cp cfg/nginx.conf bin/conf/
bin/sbin/nginx -s stop || echo 'not running'
echo 'Starting nginx...'
bin/sbin/nginx
echo 'netstat'
netstat -pant | grep 5555
echo 'error log'
tail bin/logs/error.log
