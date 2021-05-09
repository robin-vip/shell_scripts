#!/bin/sh

OLD_DIR=$(pwd)
CUR_DIR=$(dirname $0)
cd $CUR_DIR
echo "Mount device to mount point"
./mount_device.sh &

echo "Start Gogs serverice."
service gogs start

echo "Start gollum serverice."
/etc/init.d/gollum start

if [ -f "/usr/local/apache-tomcat-7.0.96/bin/startup.sh" ];then
    echo "Start jenkins serverice.(base on tomcat)"
    /usr/local/apache-tomcat-7.0.96/bin/startup.sh
fi

cd $OLD_DIR

