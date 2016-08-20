#!/bin/sh
# ================================================================== #
# Config script to backup databases and directories/files via s3cmd.
# ================================================================== #
# Version: 1.0.1
# ================================================================== #
# Parts copyright (c) 2016 Ivan.Nginx https://almostover.ru
# This script is licensed under MIT license
# ================================================================== #

MYSQLROOT=root
MYSQLPASS=
S3BUCKET=

DIRS="/etc
/root/backup-config.sh
/root/backup-exclude.txt
/var/spool/cron/root
/var/www/php-cgi
/var/www/vhosts/site.com"

# if u want to exclude files/directories, uncomment EXCLUDE variable and create backup-exclude.txt file with files/directories like this:
#/var/www/vhosts/site.com/directory
#/var/www/vhosts/site.com/file.gz
#/var/www/vhosts/site.com/backup/database*.sql*
#EXCLUDE="-X /root/backup-exclude.txt"

# the following line prefixes the backups with the defined directory. it must be blank or end with a /
S3PATH=

# when running via cron, the PATHs MIGHT be different. If you have a custom/manual MYSQL install, you should set this manually like MYSQLDUMPPATH=/usr/local/mysql/bin/
MYSQLDUMPPATH=
#tmp path.
TMP_PATH=/tmp/