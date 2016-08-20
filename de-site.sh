#!/bin/sh
# ================================================================== #
# Shell script to disable/enable site config via NGINX.
# ================================================================== #
# Version: 1.0.3
# ================================================================== #
# Parts copyright (c) 2016 Ivan.Nginx https://almostover.ru
# This script is licensed under GNU GPL version 2.0 or above
# ================================================================== #
EXPECTED_ARGS=2
DISABLED_DIR="/etc/nginx/disabled"
SITES_DIR="/etc/nginx/sites"

red='\033[00;31m'
green='\033[00;32m'
yellow='\033[00;33m'
blue='\033[01;34m'
norm='\033[00m'

if [ $# -ne $EXPECTED_ARGS ]; then
	read -p "Enter site domain: " DOMAIN
	read -p "Enter site mode (off|on|status): " MODE
	echo
	echo -e "${yellow}For command line usage:${norm} $0 ${blue}domain ${green}mode${norm}"
else
	DOMAIN="$1"
	MODE="$2"
fi

if ! [ -d $DISABLED_DIR/ ]; then
	mkdir -p $DISABLED_DIR && echo -en "\nDirectory for disabled domains successfully created.       [${green}  OK  ${norm}] -> ${blue}$DISABLED_DIR${norm}" || echo -e "ERROR"
fi

if [ -f $SITES_DIR/$DOMAIN ]; then
	CONFIG="ENABLED"
elif [ -f $DISABLED_DIR/$DOMAIN ]; then
	CONFIG="DISABLED"
else
	echo -e "\n${red}Operation was aborted.${norm} Config ${blue}${DOMAIN}${norm} is ${yellow}not exists${norm}.\n" && exit
fi

already="\n${yellow}Mode change not nedeed.${norm} Domain ${blue}${DOMAIN}${norm} already [${green}  $CONFIG  ${norm}]\n"
success="Domain mode was successfully changed.                      [${green}  OK  ${norm}] -> ${blue}${DOMAIN}${norm}\n"

if [ "$MODE" = "off" ] ; then
	if [ "$CONFIG" = "ENABLED" ] ; then
		echo -e "\nSwitching nginx domain configuration file mode to          [${yellow}  OFF ${norm}]"
		mv $SITES_DIR/$DOMAIN $DISABLED_DIR/$DOMAIN
		service nginx reload && echo -e "$success" || echo -e "ERROR"
	else
		echo -e "$already" && exit
	fi

elif [ "$MODE" = "on" ] ; then
	if [ "$CONFIG" = "DISABLED" ] ; then
		echo -e "\nSwitching nginx domain configuration file mode to          [${green}  ON  ${norm}]"
		mv $DISABLED_DIR/$DOMAIN $SITES_DIR/$DOMAIN
		service nginx reload && echo -e "$success" || echo -e "ERROR"
	else
		echo -e "$already" && exit
	fi

elif [ "$MODE" = "status" ] ; then
	echo -e "\nDomain ${blue}${DOMAIN}${norm} is [${green}  $CONFIG  ${norm}]\n" && exit
else
	echo -e "\n${red}Operation was aborted.${norm} Invalid argument ${yellow}$MODE${norm}.\n" && exit
fi
