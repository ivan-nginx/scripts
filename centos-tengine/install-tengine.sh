#!/bin/sh
# ================================================================== #
# Shell script to install Tengine and all dependencies.
# ================================================================== #
# Version: 1.0.5
# ================================================================== #
# Parts copyright (c) 2013 Knowledgebase http://www.eshosting.com/knowledgebase/75/Tengine-proxy-Web-Server-installation.html
# Parts copyright (c) 2016 Ivan.Nginx https://almostover.ru
# This script is licensed under GNU GPL version 2.0 or above
# ================================================================== #
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

SELINUX_CHECK=/usr/sbin/selinuxenabled
SELINUX_CFG=/etc/selinux/config
ARCH_CHECK=$(eval uname -m)

E_SELINUX=50
E_ARCH=51
E_NOYUM=52
E_NOSUPPORT=53
E_HASDB=54
E_REBOOT=55
E_NOTROOT=85

C_OK='\E[47;34m'"\033[1m OK \033[0m\n"
C_NO='\E[47;31m'"\033[1m NO \033[0m\n"
C_MISS='\E[47;33m'"\033[1m UNDETERMINED \033[0m\n"

# Reads yes|no answer from the input 
# 1 question text
# 2 default answer, yes = 1 and no = 0
function get_yes_no {
 local question=
 local input=
 case $2 in 
  1 ) question="$1 [Y/n]: "
   ;;
  0 ) question="$1 [y/N]: "
   ;;
  * ) question="$1 [y/n]: "
 esac

 while :
 do
  read -p "$question" input
  input=$( echo $input | tr -s '[:upper:]' '[:lower:]' )
  if [ "$input" = "" ] ; then
   if [ "$2" == "1" ] ; then
    return 1
   elif [ "$2" == "0" ] ; then
    return 0
   fi
  else
   case $input in
    y|yes) return 1
     ;;
    n|no) return 0
     ;;
   esac
  fi
 done
}

clear

# Check if user is root.
if [ "$UID" -ne "0" ] ; then
 echo -en "Installing as \"root\"        " $C_NO
 echo -e "\a\nYou must be \"root\" to install nginx.\n\nAborting ...\n"
 exit $E_NOTROOT
else
 echo -en "Installing as \"root\"        " $C_OK
fi

# Check if OS is RHEL/CENTOS.
if [ ! -f /etc/redhat-release ] ; then
 echo -en "Operating System supported  " $C_NO
 echo -e "\a\nSorry, only RedHat and CentOS are supported by this script to install nginx.\n\nAborting ...\n"
 exit $E_NOSUPPORT
else
 echo -en "Operating System supported  " $C_OK
fi

# Check if selinuxenabled exists
if [ ! -f $SELINUX_CHECK ] ; then
 echo -en "SELinux disabled            " $C_MISS
 echo -e "\a\nThe installer could not determine SELinux status.\n" \
  "If you are sure it is DISABLED, you may proceed."
 get_yes_no "Continue?" 0
 if [ "$?" -eq "0" ] ; then 
  echo -e "Aborting ...\n"
  exit $E_SELINUX
 fi
else
 # Check if SElinux is enabled from exit status. 0 = Enabled; 1 = Disabled;
 eval $SELINUX_CHECK
 OUT=$?
 if [ $OUT -eq "0" ] ; then
  echo -en "SELinux disabled            " $C_NO
  echo -e "\a\nNginx cannot be installed or executed with SELinux enabled. " \
   "The installer can disable it, but a reboot will be required.\n"
  echo -e "You will have to restart the installer again after reboot.\n"
  get_yes_no "Do you want to disable SELinux and reboot?" 1
  if [ "$?" -eq "1" ] ; then 
   echo -e "Disabling SELinux ...\n"
   cp --backup=t $SELINUX_CFG $SELINUX_CFG.old
   echo "SELINUX=disabled" > $SELINUX_CFG
   echo -e "SELinux disabled successfully\n"
   echo -e "Rebooting ...\n"
   reboot
   exit $E_REBOOT
  else
   echo -e "Please DISABLE SELinux manually and try again.\nAborting ...\n"
   exit $E_SELINUX
  fi
 elif [ $OUT -eq "1" ] ; then
  echo -en "SELinux disabled            " $C_OK
 fi
fi

# Check if yum is installed.
if ! [ -f /usr/sbin/yum ] && ! [ -f /usr/bin/yum ] ; then
 echo -en "Yum installed               " $C_NO
 echo -e "\a\nThe installer requires YUM to continue. Please install it and try again.\nAborting ...\n"
 exit $E_NOYUM
else
 echo -en "Yum installed               " $C_OK
fi

#set ipaddress
IP="127.0.0.1"
while true;do
stty -icanon min 1 time 100
echo -en "\n Please input the IP:"
read IP
 if [ "$IP" = "" ]; then
  IP="127.0.0.1"
 fi
case $IP in
*.*.*.*)
  break;;
N|n|NO|no)
  exit;;
"")  #Autocontinue
  break;;
esac
done

echo -e "\n Your IP is set to ${IP} "
	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}
	echo ""
	echo "Press any key to start install nginx..."
	char=`get_char`
	
echo ">>>>>>>>>>>>>>>> Start to install nginx......>>>>>>>>>>>>>>>>>>>>>>>"

# Start install
yum install gcc-c++ gcc make automake wget unzip flex curl -y
#yum remove httpd* -y
yum -y install patch make gcc gcc-c++ libtool libtool-libs libart_lgpl libart_lgpl-devel autoconf libjpeg libjpeg-devel libpng libpng-devel fontconfig fontconfig-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers automake
#wget http://mirror.diledns.com/linux/tengine/pcre/pcre-8.21.tar.gz
#tar zxf pcre-8.21.tar.gz
wget https://sourceforge.net/projects/pcre/files/pcre/8.38/pcre-8.38.tar.gz
tar zxf pcre-8.38.tar.gz
cd pcre-8.38/
./configure --enable-utf8 --enable-unicode-properties
make ;make install
cd ../
#wget http://mirror.diledns.com/linux/tengine/tengine-1.5.2.tar.gz
#tar zxf tengine-1.5.2.tar.gz
#cd tengine-1.5.2/
wget https://github.com/alibaba/tengine/archive/master.zip
unzip master.zip
cd tengine-master
#./configure --prefix=/usr/local/nginx
# For extended modules
yum install -y libxslt-devel gd gd-devel perl-ExtUtils-Embed GeoIP-devel
./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/lock/subsys/nginx --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --dso-path=/etc/nginx/modules --with-http_v2_module --with-file-aio --with-ipv6 --with-http_realip_module --with-http_addition_module=shared --with-http_xslt_module --with-http_image_filter_module --with-http_geoip_module=shared --with-http_sub_module=shared --with-http_dav_module --with-http_flv_module=shared --with-http_mp4_module=shared --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module=shared --with-http_secure_link_module=shared --with-http_degradation_module --with-http_perl_module --with-mail --with-mail_ssl_module --with-http_memcached_module=shared --with-debug

make ;make install
# Install all modules	make dso_install
# cd /usr/local/nginx/conf
# rm -rf /usr/local/nginx/conf/nginx.conf
# wget http://mirror.diledns.com/linux/tengine/nginx.conf
# wget http://mirror.diledns.com/linux/tengine/proxy.conf
#cd /usr/local/nginx/html
#rm -rf /usr/local/nginx/html/50x.html
#wget http://mirror.diledns.com/linux/nginx/50x.html
#wget http://mirror.diledns.com/linux/tengine/nginx
cd /etc/rc.d/init.d
wget https://raw.githubusercontent.com/ivan-nginx/scripts/master/centos-tengine/etc/rc.d/init.d/nginx
chmod 755 /etc/rc.d/init.d/nginx
cd /etc/sysconfig
wget https://raw.githubusercontent.com/ivan-nginx/scripts/master/centos-tengine/etc/sysconfig/nginx
cd /etc/logrotate.d
wget https://raw.githubusercontent.com/ivan-nginx/scripts/master/centos-tengine/etc/logrotate.d/nginx
mkdir -p /var/cache/nginx/client_temp

#sed -i 's/127.0.0.1/'$IP'/g' /usr/local/nginx/conf/proxy.conf
#sed -i 's/127.0.0.1/'$IP'/g' /usr/local/nginx/conf/nginx.conf
iptables -F
service iptables save
service iptables restart
clear
cd ~
echo "%%%%%%%%%%%%%%%%%% install finished %%%%%%%%%%%%%%%%%%%%%%%"
chkconfig nginx on
service nginx start

