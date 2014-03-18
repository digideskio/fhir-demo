function install_front {
  echo '[install front] started'
  cd fnd
  source ~/.nvm/nvm.sh
  nvm use 0.10
  nvm list
  npm install bower
  npm install grunt-cli
  npm install grunt-protractor-runner
  bower install
  `npm bin`/grunt build
  echo '[install front] finished'
}
