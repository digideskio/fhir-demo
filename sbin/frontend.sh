function install_front {
  cd fnd
  which node || (echo 'install nvm && node' && exit 1)
  nvm use 0.10
  npm install -g bower
  bower install
}
