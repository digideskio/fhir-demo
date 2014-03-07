function install_front {
  cd fnd
  which nvm || (echo 'install nvm' && exit 1)
  nvm use 0.10
  npm install -g bower
  bower install
}
