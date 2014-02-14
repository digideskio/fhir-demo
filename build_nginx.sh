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
