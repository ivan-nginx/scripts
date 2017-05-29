#!/bin/sh
# ================================================================== #
# Shell script to update Tengine and all dependencies.
# ================================================================== #
# Version: 1.0.1
# ================================================================== #
# Parts copyright (c) 2013 Knowledgebase http://www.eshosting.com/knowledgebase/75/Tengine-proxy-Web-Server-installation.html
# Parts copyright (c) 2017 Ivan.Nginx https://almostover.ru
# This script is licensed under GNU GPL version 2.0 or above
# ================================================================== #
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo ">>>>>>>>>>>>>>>> Start to update nginx......>>>>>>>>>>>>>>>>>>>>>>>"
service nginx stop

# Start update
cd /tmp
wget https://github.com/alibaba/tengine/archive/master.zip
unzip master.zip
cd tengine-master
./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --dso-path=/etc/nginx/modules --with-http_v2_module --with-file-aio --with-ipv6 --with-http_realip_module --with-http_addition_module=shared --with-http_xslt_module --with-http_image_filter_module --with-http_geoip_module=shared --with-http_sub_module=shared --with-http_dav_module --with-http_flv_module=shared --with-http_mp4_module=shared --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module=shared --with-http_secure_link_module=shared --with-http_degradation_module --with-http_perl_module --with-mail --with-mail_ssl_module --with-http_memcached_module=shared --with-debug
make ;make install

# Install all modules
#make dso_install

clear
cd ~
echo "%%%%%%%%%%%%%%%%%% update finished %%%%%%%%%%%%%%%%%%%%%%%"
service nginx start
