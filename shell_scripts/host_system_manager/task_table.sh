#!/bin/sh
OLD_DIR=$(pwd)
CUR_DIR=$(dirname $0)
cd $CUR_DIR
echo "Mount device to mount point"
./mount_device.sh &

cd $OLD_DIR
