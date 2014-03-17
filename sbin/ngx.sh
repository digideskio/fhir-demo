function reload_ngx {
  cat cfg/nginx.conf | sed "s/PGDATABASE/$PGDATABASE/g" | sed "s/PGPORT/$PGPORT/g" | sed "s/PGUSER/$PGUSER/g" | sed "s/PGPASSWORD/$PGPASSWORD/g" | sed "s|WEBROOT|$FHIR_ROOT/fnd|g" | sed "s|FHIR_ROOT|$FHIR_ROOT|g" | sed "s/NGXPORT/$NGXPORT/g" | sed "s/NGXUSER/$NGXUSER/g" > bin/nginx/conf/nginx.conf

  bin/nginx/sbin/nginx -s stop || echo 'not running'
  echo 'Starting nginx...'
  bin/nginx/sbin/nginx
  echo 'netstat'
  netstat -pant | grep "$NGXPORT"
}

function install_ngnx {
  git submodule init
  git submodule update
  sudo apt-get install libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make
  BLD=`pwd`/bin
  cd ngx_openresty/

  PATH=$PATH:/sbin/

  make

  cd  ngx_openresty-1.5.9.1rc1

  ./configure --prefix=$BLD \
    --with-luajit \
    --with-http_postgres_module
    -j4

  make
  make install
}

