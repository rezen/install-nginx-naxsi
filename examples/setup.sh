#!/bin/bash

# @todo create an argument to force update
set -e
set -o errtrace

readonly target_dir=/var/www/html/examples

is_sudo()
{
  [[ `id -u` -eq 0 ]]
}

# @todo a cleanup script to remove php
install_deps_apt()
{
  {
    which php
  } || {
    sudo apt-get update
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    sudo apt-get install -y php7.0 php7.0-mysql php7.0-fpm php7.0-sqlite3
  }
}

setup_examples() 
{
  if [ ! -f "$target_dir/sql.php" ]; then
    sudo mkdir -p $target_dir
    cp ./*.* $target_dir
  fi

  chown -R www-data:www-data $target_dir
}

nginx_conf()
{
  local conf=/etc/nginx/sites-available/examples

  if [ ! -f "$conf" ]; then
    cp ./examples /etc/nginx/sites-available/examples
  fi

  rm /etc/nginx/sites-enabled/default

  ln -nfs /etc/nginx/sites-available/examples /etc/nginx/sites-enabled/examples
  find /etc/nginx -type f -exec chmod 644 {} \;
  service nginx restart
}

main()
{
  if ! is_sudo; then
    echo '[!] Please run this as sudo'
    exit 1
  fi
  install_deps_apt
  setup_examples
  nginx_conf
}

handle_error()
{
  echo "[failed][$0] line $1, exit code $2"
  exit $2
}

trap 'handle_error $LINENO $?' ERR 

main