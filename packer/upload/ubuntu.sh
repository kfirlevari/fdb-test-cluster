#!/bin/bash
set -e
set -x

# from http://unix.stackexchange.com/a/28793
# if we aren't root - elevate. This is useful for AMI
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

export DEBIAN_FRONTEND=noninteractive

# set timezone to UTC
dpkg-reconfigure tzdata

# https://groups.google.com/forum/#!msg/foundationdb-user/BtJf-1Mlx4I/fxXZClLpnOUJ
# sources: https://github.com/ripple/docker-fdb-server/blob/master/Dockerfile
# https://hub.docker.com/r/arypurnomoz/fdb-server/~/dockerfile/

# linux-aws - https://forums.aws.amazon.com/thread.jspa?messageID=769521&tstart=0

# need to clean since images could have stale metadata
apt-get clean && apt-get update
apt-get install -y -qq build-essential python linux-aws sysstat iftop htop iotop ne default-jdk maven unzip bc

# install fdbtop
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y -qq nodejs
npm install -g fdbtop

#install protoc
PROTOC_ZIP=protoc-3.3.0-linux-x86_64.zip
curl -OL https://github.com/google/protobuf/releases/download/v3.3.0/$PROTOC_ZIP
unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
rm -f $PROTOC_ZIP

######### FDB

cd /tmp

# download the dependencies
wget https://www.foundationdb.org/downloads/5.2.5/ubuntu/installers/foundationdb-clients_5.2.5-1_amd64.deb
wget https://www.foundationdb.org/downloads/5.2.5/ubuntu/installers/foundationdb-server_5.2.5-1_amd64.deb

# server depends on the client packages
dpkg -i foundationdb-clients_5.2.5-1_amd64.deb
dpkg -i foundationdb-server_5.2.5-1_amd64.deb

# stop the service
service foundationdb stop

# add default user to foundationdb group
sudo usermod -a -G foundationdb ubuntu

# ensure correct permissions
chown -R foundationdb:foundationdb /etc/foundationdb
chmod -R ug+w /etc/foundationdb

######### YCSB

unzip -o /tmp/ycsb.zip -d /usr/local
mv /usr/local/ycsb-master /usr/local/ycsb

cd /usr/local/ycsb
mvn -pl com.yahoo.ycsb:foundationdb-binding -am clean package -DskipTests -U
mvn -pl com.yahoo.ycsb:fdbrecordlayer-binding -am clean package -DskipTests -U
chmod -R 777 /usr/local/ycsb

mkdir /usr/local/etc/foundationdb/
cp /etc/foundationdb/fdb.cluster /usr/local/etc/foundationdb/

cp /tmp/*.sh /usr/local/ycsb/

######### Cleanup

apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
