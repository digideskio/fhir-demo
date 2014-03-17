function install_front {
  cd fnd
  nvm use 0.10
  npm install -g bower
  bower install
}
