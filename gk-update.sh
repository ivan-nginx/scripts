#!/bin/sh
# ================================================================== #
# Shell script to install/update GitKraken under RHEL/Fedora/CentOS.
# ================================================================== #
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[00;31m'
green='\033[00;32m'
yellow='\033[00;33m'
blue='\033[01;34m'
norm='\033[00m'
bold='\033[1m'

column=50
alignment="\\033[${column}G"

# Status variables.
C_OK="$alignment [ ${green} OK ${norm} ]\n"
C_OK_BOLD="$alignment ${green}[ ${bold} OK ${green} ]${norm}\n"
C_NO="$alignment [ ${red} NO ${norm} ]\n"
C_NO_BOLD="$alignment ${red}[ ${bold} NO ${red} ]${norm}\n"

# Checking OS & root variables.
E_NOSUPPORT=53
E_NOTROOT=85

# Application name.
APP_NAME='gitkraken'

# Arguments.
EXPECTED_ARGS=1

# Checking if OS is RHEL/Fedora/CentOS.
if [ ! -f /etc/redhat-release ] ; then
    echo -en "Checking for support OS:" $C_NO
    echo -e "\a\nSorry, only RedHat, Fedora and CentOS are supported by this script to install/update $APP_NAME.\n\nAborting...\n"
    exit $E_NOSUPPORT
else
    echo -en "Checking for support OS:" $C_OK
fi

# Checking if user is root.
if [ "$UID" -ne "0" ] ; then
    echo -en "Checking for \"root\" access:" $C_NO
    echo -e "\a\nYou must be \"root\" to install $APP_NAME.\n\nAborting...\n"
    exit $E_NOTROOT
else
    echo -en "Checking for \"root\" access:" $C_OK
fi

# If no arguments defined, setting into interactive mode.
if [ $# -ne $EXPECTED_ARGS ]; then
    read -p "Enter username under whom program will start (press enter to default \"ivan-nginx\"): " USER_NAME
    USER_NAME=${USER_NAME:-ivan-nginx}
    echo
    echo -e "${yellow}For command line usage:${norm} $0 ${blue}blogname ${norm}"
else
    USER_NAME="$1"
fi

echo
echo "=============================================================="
echo " Downloading GitKraken..."
echo "=============================================================="
    cd /opt
    wget https://release.gitkraken.com/linux/gitkraken-amd64.tar.gz

echo
echo "=============================================================="
echo " Installing GitKraken..."
echo "=============================================================="
    tar -xvzf gitkraken-amd64.tar.gz
    rm -f gitkraken-amd64.tar.gz
    chown -R $USER_NAME:$USER_NAME gitkraken
