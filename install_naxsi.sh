#!/bin/bash

# @todo create an argument to force update
set -e
set -o errtrace

readonly CONF_DIR="$1"
readonly NAXSI_VER=0.54
readonly NGINX_VER=1.11.1

is_empty_dir() 
{
  local dir="$1"
  [ ! "$(ls -A $dir)" ]
}

is_sudo()
{
  [[ `id -u` -eq 0 ]]
}

install_deps_apt()
{
  sudo apt-get update
  sudo apt-get install -y build-essential bzip2 libpcre3-dev libssl-dev daemon libgeoip-dev git
}

prepare_sources()
{
  # Skip re-installing nginx unless a force argument is passed
  if [ -f /usr/sbin/nginx ]; then
    return 0
  fi
  sudo mkdir -p /opt
  cd /opt

  install_deps_apt

  curl https://nginx.org/keys/nginx_signing.key | apt-key add -
  gpg --keyserver pgp.mit.edu --recv-keys 0x251A28DE2685AED4 7BD9BF62 A1C052F8
  prepare_nginx "${NGINX_VER}"
  prepare_mod_naxsi "${NAXSI_VER}"
  prepare_mod_test_cookie
  prepare_mod_more_headers
}

setup_tar()
{  
  local tarball="$1"
  local output="$2"

  if [ ! -d "$output" ]; then
    mkdir -p $output
  fi

  if is_empty_dir "/opt/$output"; then
    tar -xvzf $tarball -C $output --strip-components 1
  fi
}

prepare_nginx()
{
  local version="$1"

  cd /opt

  if [ ! -f nginx-$version.tar.gz ]; then    
    wget http://nginx.org/download/nginx-$version.tar.gz
    wget http://nginx.org/download/nginx-$version.tar.gz.asc
  fi

  gpg --verify nginx-$version.tar.gz.asc nginx-$version.tar.gz
  tar -xvzf nginx-$version.tar.gz
}

# https://github.com/openresty/headers-more-nginx-module#installation
prepare_mod_more_headers()
{
  local tar_file='mod-headers-more.tar.gz'
  local named='mod-headers-more'
  
  cd /opt

  if [ ! -f "/opt/$tar_file" ]; then
    wget https://github.com/openresty/headers-more-nginx-module/archive/v0.30.tar.gz -O $tar_file
  fi

  setup_tar "$tar_file" "$named"
}

prepare_mod_naxsi()
{
  local version="$1"
  local tar_file="mod-naxsi-$version.tar.gz"
  local named="mod-naxsi-$version"

  cd /opt

  if [ ! -f "/opt/$tar_file" ]; then
    wget https://github.com/nbs-system/naxsi/archive/$version.tar.gz -O $tar_file
    wget https://github.com/nbs-system/naxsi/releases/download/$version/$version.tar.gz.asc
  fi

  gpg --verify $version.tar.gz.asc $tar_file

  setup_tar "$tar_file" "$named"
}

prepare_mod_test_cookie()
{
  local tar_file='mod-test-cookie.tar.gz'
  local named="mod-test-cookie"
  cd /opt

  if [ ! -f "$tar_file" ]; then
    wget https://github.com/kyprizel/testcookie-nginx-module/archive/master.tar.gz -O $tar_file
  fi

  setup_tar "$tar_file" "$named"
}

setup_user()
{
  id -u www-data &>/dev/null || adduser --system --no-create-home --disabled-login --disabled-password --group www-data
}

install_nginx()
{
  local nginx_version="$1"
  local naxsi_version="$2"

  if [ -f /usr/sbin/nginx ]; then
    return 0
  fi

  sudo mkdir -p /var/lib/nginx

  cd nginx-$nginx_version

  # http://nginx.org/en/docs/configure.html
  ./configure \
  --conf-path=/etc/nginx/nginx.conf \
  --add-dynamic-module=../mod-naxsi-$naxsi_version/naxsi_src/ \
  --add-dynamic-module=../mod-headers-more/ \
  --add-dynamic-module=../mod-test-cookie/ \
  --error-log-path=/var/log/nginx/error.log \
  --http-client-body-temp-path=/var/lib/nginx/body \
  --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
  --http-log-path=/var/log/nginx/access.log \
  --http-proxy-temp-path=/var/lib/nginx/proxy \
  --lock-path=/var/lock/nginx.lock \
  --pid-path=/var/run/nginx.pid \
  --user=www-data \
  --group=www-data \
  --with-http_ssl_module \
  --with-http_geoip_module \
  --with-http_realip_module \
  --without-mail_pop3_module \
  --without-mail_smtp_module \
  --without-mail_imap_module \
  --without-http_scgi_module \
  --prefix=/usr
  
  make
  make install
}

nginx_conf_boilerplate()
{
  if [ ! -f nginx-boilerplate.tar.gz ]; then
    wget https://github.com/nginx-boilerplate/nginx-boilerplate/archive/0.3.3.tar.gz -O nginx-boilerplate.tar.gz
    tar -xvzf nginx-boilerplate.tar.gz -C /etc/nginx --strip-components 1
    rm -rf /etc/nginx/sites-*
    rm /etc/nginx/boilerplate/upstreams/nginx.boilerplate.conf
  fi
}

nginx_conf_h5bp()
{
  if [ ! -f h5bp-nginx.tar.gz ]; then
    wget https://github.com/h5bp/server-configs-nginx/archive/master.tar.gz  -O h5bp-nginx.tar.gz
    mkdir -p /tmp/h5bp-nginx
    tar -zkf h5bp-nginx.tar.gz -C /tmp/h5bp-nginx --strip-components 1
    cp -R /tmp/h5bp-nginx/h5bp/ /etc/nginx/
  fi
}

naxsi_com_rules()
{
  if [ ! -f naxsi-com-rules.tar.gz ]; then
    echo '[i] Adding naxsi rules for common web platforms'
    wget https://github.com/nbs-system/naxsi-rules/archive/master.tar.gz -O naxsi-com-rules.tar.gz
    {
      tar -xkzf naxsi-com-rules.tar.gz -C /etc/nginx/naxsi --strip-components 1 2>/dev/null
    }  || { echo; }
  fi
}

# @todo setting up config should be it's own script
update_configs()
{
  { 
    service nginx start 
  } || { echo; }

  cd /opt

  # nginx_conf_boilerplate
  # nginx_conf_h5bp

  mkdir -p /etc/nginx/sites-available
  mkdir -p /etc/nginx/sites-enabled
  mkdir -p /etc/nginx/naxsi
  mkdir -p /etc/nginx/conf

  if [ -f /etc/nginx/fastcgi_params ]; then
    mv /etc/nginx/fastcgi_params /etc/nginx/conf/fastcgi_params
    mv /etc/nginx/mime.types /etc/nginx/conf/mime.types
    mv /etc/nginx/uwsgi_params /etc/nginx/conf/uwsgi_params
  fi

  find /etc/nginx -maxdepth 1 -type f -exec rm {} \;

  if [ ! -f "/etc/init.d/nginx" ]; then
    cp -f $CONF_DIR/init.d/nginx /etc/init.d/nginx
    chmod 755 /etc/init.d/nginx
  fi

  cp -f $CONF_DIR/nginx.conf /etc/nginx/nginx.conf

  if [ ! -f /etc/nginx/naxsi.conf ]; then
    cp -fR $CONF_DIR/conf/* /etc/nginx/conf
    cp -fR $CONF_DIR/naxsi/* /etc/nginx/naxsi
    cp -f $CONF_DIR/naxsi.conf /etc/nginx/naxsi.conf
    cp -f $CONF_DIR/sites-available/default /etc/nginx/sites-available/default
    ln -nfs /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default 
  fi

  naxsi_com_rules

  find /etc/nginx -type f -print -exec chmod 644 {} \;

  {
    service nginx reload
    service nginx stop
    service nginx start
  } || { echo '[i] Restarted nginx'; }
}

setup_www() 
{
  if [ ! -d /var/www/html ]; then
    sudo mkdir -p /var/www/html
    echo 'Hello!' > /var/www/html/index.html
    sudo chown -R www-data:www-data /var/www/html
  fi
}

main()
{
  if [ ! -d "$CONF_DIR" ]; then
    echo '[!] Please provide a conf source directory'
    exit 1
  fi

  setup_user
  prepare_sources
  install_nginx "${NGINX_VER}" "${NAXSI_VER}"
  setup_www
  update_configs
}

handle_error()
{
  echo "[failed][$0] line $1, exit code $2"
  exit $2
}

trap 'handle_error $LINENO $?' ERR 

main