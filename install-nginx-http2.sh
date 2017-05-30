#!/bin/sh

##############################################################################################
## Install Nginx with OpenSSL (HTTP2) and ngx_pagespeed, adapted on CentOS
## Author: Andrew Maxwell <amaxwell@traffixdevices.com>
##       & Ivan Nginx <ivan.nginx@gmail.com>
## Date: 2017-05-30
## Version: 0.2
##
## original script was taken from:
## https://gist.github.com/AJMaxwell/f6793605068813aae888216b02364d85
## ngx_pagespeed code adapted from:
## https://developers.google.com/speed/pagespeed/module/build_ngx_pagespeed_from_source
## openssl code adapted from:
## https://www.digitalocean.com/community/questions/how-to-get-already-installed-nginx-to-use-openssl-1-0-2-for-alpn#answer_27588
##############################################################################################

# Current version of nginx, openssl, and ngx_pagespeed you want to install
NGINX_VERSION=1.12.0
OPENSSL_VERSION=1.0.2l
NPS_VERSION=1.11.33.4
TEMP=/tmp

##############################################################################################
########## STOP EDITING
##############################################################################################

## Currently installed version of openssl
OPENSSL_CURRENT_VERSION=$(openssl version | awk '{ print $2 }')
## Nginx ./configure flags
# Automagically grab current Nginx flags
#NGINX_USER_FLAGS="$(nginx -V  2>&1 | tail -1| tr ' ' '\n' | tail -n +3)"
# Or use default Nginx flags
#NGINX_USER_FLAGS="--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-http_perl_module=dynamic --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_v2_module"

# Remove dynamic modules ([emerg] module "/etc/nginx/modules/ngx_stream_geoip_module.so" is not binary compatible)
# Add --with-compat directive to prefix
NGINX_USER_FLAGS="--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_v2_module"
OPENSSL_FLAGS="--with-openssl=$TEMP/openssl-$OPENSSL_VERSION"
NPS_FLAGS="--add-module=$TEMP/ngx_pagespeed-release-$NPS_VERSION-beta"
# https://github.com/pagespeed/ngx_pagespeed/issues/1079
# https://modpagespeed.com/doc/build_ngx_pagespeed_from_source
PS_NGX_EXTRA_FLAGS="--with-cc=/opt/rh/devtoolset-2/root/usr/bin/gcc"
NGINX_FLAGS="$NGINX_USER_FLAGS $OPENSSL_FLAGS $NPS_FLAGS $PS_NGX_EXTRA_FLAGS"

#yum -y groupinstall 'Development Tools'
#yum -y install wget openssl-devel libxml2-devel libxslt-devel gd-devel perl-ExtUtils-Embed GeoIP-devel pcre-devel
#yum -y install rpmdevtools && rpmdev-setuptree

# Ensure lib and build packages are installed
yum install gcc-c++ gcc make automake wget unzip flex curl -y
yum -y install patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers automake
wget https://sourceforge.net/projects/pcre/files/pcre/8.38/pcre-8.38.tar.gz
tar zxf pcre-8.38.tar.gz
cd pcre-8.38/
./configure --enable-utf8 --enable-unicode-properties
make ;make install

## Ensure we are in tmp directory
cd $TEMP

## Download sources
# Download nginx
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
# Download openssl
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
# Download ngx_pagespeed
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip

## Extract sources
# Extract nginx
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
# Extract openssl
tar -xvzf openssl-${OPENSSL_VERSION}.tar.gz
# Extract ngx_pagespeed
unzip release-${NPS_VERSION}-beta.zip

## Download and Extract PSOL (PageSpeed Optimization Library)
cd ngx_pagespeed-release-${NPS_VERSION}-beta/
wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz
tar -xzvf ${NPS_VERSION}.tar.gz # extracts to psol/
cd $TEMP

## Install openssl
cd openssl-${OPENSSL_VERSION}/
./config
make depend
make
make test
make install
mv /usr/bin/openssl /usr/bin/openssl_${OPENSSL_CURRENT_VERSION}
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl
cd $TEMP

## Install nginx + ngx_pagespeed
cd nginx-${NGINX_VERSION}/
./configure ${NGINX_FLAGS}
make
make install

echo "Installation Complete!"
