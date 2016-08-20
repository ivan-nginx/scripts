#!/bin/sh
# ================================================================== #
# Shell script to add a mysql database and user with db access.
# ================================================================== #
# Version: 1.0.2
# ================================================================== #
# Parts copyright (c) 2011 Rob Schmitt http://www.bluepiccadilly.com/2011/12/creating-mysql-database-and-user-command-line-and-bash-script-automate-process
# Parts copyright (c) 2011 nbanba http://www.bluepiccadilly.com/2011/12/creating-mysql-database-and-user-command-line-and-bash-script-automate-process#comment-2179777540
# Parts copyright (c) 2012 Matt Thomas http://betweenbrain.com
# Parts copyright (c) 2016 Ivan.Nginx https://almostover.ru
# This script is licensed under GNU GPL version 2.0 or above
# ================================================================== #
EXPECTED_ARGS=4
#E_BADARGS=65
MYSQL=`which mysql`

red='\033[01;31m'
blue='\033[01;34m'
green='\033[01;32m'
norm='\033[00m'

if [ $# -ne $EXPECTED_ARGS ]; then
	#read -s -p "Enter your MySQL root password: " MYSQLPW
	read -p "Enter your MySQL root password: " MYSQLPW
	read -p "Enter new database name: " DB
	read -p "Enter new username: " USER
	read -p "Enter password for this user: " PW
	echo
	echo "For command line usage: $0 rootpass dbname dbuser dbpass"
	#exit $E_BADARGS
else
	MYSQLPW="$1"
	DB="$2"
	USER="$3"
	PW="$4"
fi

Q1="CREATE DATABASE IF NOT EXISTS \`$DB\` CHARACTER SET utf8 COLLATE utf8_general_ci;"
Q2="GRANT USAGE ON *.* TO '$USER'@localhost IDENTIFIED BY '$PW';"
Q3="GRANT ALL PRIVILEGES ON \`$DB\`.* TO '$USER'@'localhost' IDENTIFIED BY '$PW';"
Q4="FLUSH PRIVILEGES;"
QUERY="${Q1}${Q2}${Q3}${Q4}"

echo -e "\n${blue}Creating mysql DATABASE ${red}${DB}${norm}\n${blue}Creating mysql USER ${red}${USER}${norm}\n"
for QUERY in "$Q1" "$Q2" "$Q3" "$Q4"
do
$MYSQL -uroot -p$MYSQLPW -e "$QUERY" && echo -e "$QUERY ---> [${green}OK${norm}]" || echo -e "$QUERY ---> [${red}ERROR${norm}]"

done
echo -e " "
