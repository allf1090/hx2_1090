#!/bin/bash

#Bot setup V2 1090 - RedHat Version
#Adding startup support for client.
#Making client run forever.

#define static variables.
NODE_URL="https://rpm.nodesource.com/setup_10.x"                                                #V10 most stable release.
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

echo "installing dependencies [unzip, golang, nodejs hping3]"
echo y | yum update
echo y | yum install epel-release -y
echo y | yum install curl -y
echo y | yum install wget -y
echo y | yum install unzip -y
echo y | yum install hping3 -y
#echo y | yum install cron 

#install golang
if [ "$arch" == 'x86_64' ]
then
    wget $GOLANG_URL_64
    tar -zxvf "${CWD}/go1.8.3.linux-amd64.tar.gz" -C /usr/local
    rm -r "${CWD}/go1.8.3.linux-amd64.tar.gz"
    echo "golang  ->  done"
else
    wget $GOLANG_URL_32
    tar -zxvf "${CWD}/go1.8.3.linux-386.tar.gz" -C /usr/local
    rm -r "${CWD}/go1.8.3.linux-386.tar.gz"
    echo "golang  ->  done"
fi

#getting nodejs updated version.
echo "Installing nodejs stable version."
curl -sL $NODE_URL | bash -
echo y | yum install nodejs -y
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
