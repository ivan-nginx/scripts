#!/bin/sh
# ================================================================== #
# Shell script to add a new site (virtual host) to NGINX and Apache.
# ================================================================== #
# Version: 1.0.2
# ================================================================== #
# Parts copyright (c) 2012 Matt Thomas http://betweenbrain.com
# Parts copyright (c) 2016 Ivan.Nginx https://almostover.ru
# This script is licensed under GNU GPL version 2.0 or above
# ================================================================== #
E_NOTROOT=85
#E_USEREXISTS=70

C_OK='\E[47;34m'"\033[1m OK \033[0m\n"
C_NO='\E[47;31m'"\033[1m NO \033[0m\n"

# Check if user is root.
if [ "$UID" -ne "0" ] ; then
	echo -e "\a\nYou must be \"root\" to run this script.\n\nAborting ...\n"
	exit $E_NOTROOT
#else
#	echo -en "Running as \"root\"        " $C_OK
fi

read -p "Enter new site domain: " DOMAIN
read -p "Enter new or existing user: " USER
echo
# Check if user already exists.
grep -q "$USER" /etc/passwd
if [ $? -ne 0 ] ; then
	echo "User \"$USER\" does not exist. Creating user."
	useradd $USER
	echo -e "User \"$USER\" successfully created." $C_OK
else
	echo -e "User \"$USER\" already exist." $C_OK
	#exit $E_USEREXISTS
fi

echo "Checking fcgi wrapper for \"$DOMAIN\""
echo "--------------------------------------------------------------"
if ! [ -d /var/www/php-cgi/$DOMAIN/ ]; then
	mkdir -p /var/www/php-cgi/$DOMAIN
	echo -en "Directory /var/www/php-cgi/$DOMAIN/ successfully created." $C_OK
else
	echo -en "Directory /var/www/php-cgi/$DOMAIN/ already exist." $C_OK
fi

if ! [ -f /var/www/php-cgi/$DOMAIN/php.cgi ]; then
echo "#!/bin/sh
PHPRC=/etc/
export PHPRC
export PHP_FCGI_MAX_REQUESTS=1000
export PHP_FCGI_CHILDREN=0
exec /usr/bin/php-cgi" > /var/www/php-cgi/$DOMAIN/php.cgi

	chmod 755 /var/www/php-cgi/$DOMAIN/php.cgi
	chown -R $USER:$USER /var/www/php-cgi/$DOMAIN
	echo -e "File /var/www/php-cgi/$DOMAIN/php.cgi successfully created, chmoded and owned by \"$USER\"." $C_OK
else
	echo -e "File /var/www/php-cgi/$DOMAIN/php.cgi already exist." $C_OK
fi

echo "Checking directories for domain \"$DOMAIN\""
echo "--------------------------------------------------------------"
if ! [ -d /var/www/vhosts/$DOMAIN/ ]; then
	mkdir -p /var/www/vhosts/$DOMAIN
	echo -en "Directory /var/www/vhosts/$DOMAIN successfully created." $C_OK
	echo "<?php echo phpinfo(); ?>" > /var/www/vhosts/$DOMAIN/index.php
	echo -e "PHPInfo file in root $DOMAIN successfully created." $C_OK
else
	echo -e "Directory /var/www/vhosts/$DOMAIN already exist." $C_OK
fi

echo "Setting correct ownership and permissions for \"$DOMAIN\""
echo "--------------------------------------------------------------"
	chown -R $USER:$USER /var/www/vhosts/$DOMAIN
	find /var/www/vhosts/$DOMAIN/ -type d -exec chmod 755 {} \;
	echo -en "All directories in /var/www/vhosts/$DOMAIN chowned on 755." $C_OK
	find /var/www/vhosts/$DOMAIN/ -type f -exec chmod 644 {} \;
	echo -e "All files in /var/www/vhosts/$DOMAIN chowned on 644." $C_OK

echo "Creating VirtualHost for \"$DOMAIN\""
echo "--------------------------------------------------------------"
if ! [ -d /var/log/httpd/ ]; then
	mkdir /var/log/httpd
	echo -en "Directory /var/log/httpd/ successfully created." $C_OK
fi
	touch /var/log/httpd/$DOMAIN-access.log
	touch /var/log/httpd/$DOMAIN-error.log

if ! [ -d /etc/httpd/conf.d/ ]; then
	mkdir -p /etc/httpd/conf.d
	echo -en "Directory /etc/httpd/conf.d/ successfully created." $C_OK
fi

if ! [ -f /etc/httpd/conf.d/$DOMAIN.conf ]; then
	echo "#NameVirtualHost 127.0.0.1:8080 # for first site
<VirtualHost 127.0.0.1:8080>
	DocumentRoot /var/www/vhosts/$DOMAIN
	ServerName $DOMAIN
	ServerAlias www.$DOMAIN
	CustomLog /var/log/httpd/$DOMAIN-access.log combined
	ErrorLog /var/log/httpd/$DOMAIN-error.log
	#SetEnvIf X-Forwarded-Proto https HTTPS=on # for HTTPS

	<IfModule mod_fcgid.c>
		SuexecUserGroup $USER $USER
		<Directory /var/www/vhosts/$DOMAIN>
			Options +ExecCGI
			AllowOverride All
			AddHandler fcgid-script .php
			FCGIWrapper /var/www/php-cgi/$DOMAIN/php.cgi .php
			Order allow,deny
			Allow from all
		</Directory>
	</IfModule>
</VirtualHost>" > /etc/httpd/conf.d/$DOMAIN.conf
	echo -e "File /etc/httpd/conf.d/$DOMAIN.conf successfully created." $C_OK
else
	echo -e "File /etc/httpd/conf.d/$DOMAIN.conf already exist." $C_OK
fi

echo "Creating NGINX server for \"$DOMAIN\""
echo "--------------------------------------------------------------"
if ! [ -d /etc/nginx/conf.d/ ]; then
	mkdir /etc/nginx/conf.d
	echo -en "Directory /etc/nginx/conf.d/ successfully created." $C_OK
fi

if ! [ -f /etc/nginx/conf.d/default.conf ]; then
echo "server {
	listen *:80 default_server;
	server_name _;

	return 444;
}

server {
	listen *:443 default_server;
	server_name _;

	server_name_in_redirect off;

	ssl on;
	ssl_certificate      /etc/nginx/ssl/server.crt;
	ssl_certificate_key  /etc/nginx/ssl/server.key;

	return 444;
}" > /etc/nginx/conf.d/default.conf
	echo -e "File /etc/nginx/conf.d/default.conf successfully created." $C_OK
else
	echo -e "File /etc/nginx/conf.d/default.conf already exist." $C_OK
fi

if ! [ -d /etc/nginx/sites/ ]; then
	mkdir /etc/nginx/sites
	echo -en "Directory /etc/nginx/sites/ successfully created." $C_OK
fi

if ! [ -f /etc/nginx/sites/$DOMAIN ]; then
	echo '# Redirect all www to non-www
server {
	if ($legal_ip){set $bad_country 0;}
	if ($bad_country){return 444;}

	listen               *:80;
	#listen               *:443 ssl http2;
	#listen               [::]:80 ipv6only=on;
	#listen               [::]:443 ssl http2 ipv6only=on;
	server_name www.'$DOMAIN';

	#ssl_certificate      /etc/nginx/ssl/'$DOMAIN'.crt;
	#ssl_certificate_key  /etc/nginx/ssl/'$DOMAIN'.key;

	return 301 $scheme://'$DOMAIN$'$request_uri;
}

server {
	limit_conn addr 100;
	limit_conn perip 100;
	limit_conn perserver 1000;

	if ($legal_ip){set $bad_country 0;}
	if ($bad_country){return 444;}

	listen               *:80;
	#listen *:443 ssl http2;
	#listen [::]:443 ssl http2;
	server_name '$DOMAIN';

	#keepalive_timeout   70;

# If SSL
	#ssl_certificate      /etc/nginx/ssl/'$DOMAIN'.crt;
	#ssl_certificate_key  /etc/nginx/ssl/' $DOMAIN'.key;

	#ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	#ssl_prefer_server_ciphers on;
	#ssl_ciphers "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:ECDHE-RSA-RC4-SHA:ECDHE-ECDSA-RC4-SHA:RC4-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK";

	# Generate dhparam.pem	openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
	#ssl_dhparam /etc/nginx/ssl/dhparam.pem;

	#resolver 8.8.8.8;
	#ssl_stapling on;
	#ssl_trusted_certificate /etc/nginx/ssl/star_forgott_com.crt;
 
	#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";

# Path for static files at Reverse Proxy (cache); Path to root dir with html-files without Apache/PHP
	root /var/www/vhosts/'$DOMAIN';
	index index.php index.html index.htm;

	location ~* ^.+.(?:jpg|jpeg|gif|png|ico|css|zip|tgz|gz|rar|bz2|doc|xls|exe|pdf|ppt|txt|tar|mid|midi|wav|bmp|rtf|js|swf|svg|svgz|mp4|ogg|ogv|webm|htc|ttf|ttc|otf|eot|woff|font.css)$ {
		expires 7d;
		access_log off;
		log_not_found off;
		error_page 404 = @try_apache;
}

	location @try_apache {
		access_log off;
		proxy_pass		http://apache;
		proxy_http_version	1.1;
		proxy_redirect		off;
		proxy_set_header	Host $host;
		proxy_set_header	X-Real-IP $remote_addr;
		proxy_headers_hash_bucket_size 128;
		proxy_set_header	X-Forwarded-For $proxy_add_x_forwarded_for;
		#proxy_set_header	X-Forwarded-For $remote_addr;
		#proxy_set_header	X-Forwarded-For $geoip_country_code;
		#proxy_set_header	X-Forwarded-Proto $scheme;
		}

# Send all traffic to the back-end
	location / {
		proxy_pass		http://apache;
		proxy_http_version	1.1;
		proxy_redirect		off;
		proxy_set_header	Host $host;
		proxy_set_header	X-Real-IP $remote_addr;
		proxy_headers_hash_bucket_size 128;
		proxy_set_header	X-Forwarded-For $proxy_add_x_forwarded_for;
		#proxy_set_header	X-Forwarded-For $remote_addr;
		#proxy_set_header	X-Forwarded-For $geoip_country_code;
		#proxy_set_header	X-Forwarded-Proto $scheme;
		}
}' > /etc/nginx/sites/$DOMAIN
	echo -e "File /etc/nginx/sites/$DOMAIN successfully created." $C_OK
else
	echo -e "File /etc/nginx/sites/$DOMAIN already exist." $C_OK
fi


echo "Site $DOMAIN ready. Reloading Apache and NGINX"
echo "--------------------------------------------------------------"
	service httpd reload
	service nginx reload
