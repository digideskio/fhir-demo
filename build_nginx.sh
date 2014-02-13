BLDP="`pwd`/bin"
echo "Building nginx into $BLDP"
cd ngx/nginx
# --with-pcre=../pcre-8.34
./configure --prefix=$BLDP \
  --add-module=../ngx_postgres \
  --add-module=../ngx_devel_kit \
  --add-module=../form-input-nginx-module \
  --add-module=../echo-nginx-module
make -j2
make install
cd ../..
