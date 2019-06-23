#!/bin/sh
# Add automatic mount device to mount point.
# Create by sunrise in 09/05/2014

DeviceNode=""
MountPoint=""

PromtMountFail(){
	echo "Warning: mount \"$1\" to \"$2\" failed!"
}

MountDevice(){
echo 
if [ ! -b $1 ]; then
	PromtMountFail $1 $2
	echo "device node \"$1\" is not existed"
	return 1
fi

if [ ! -d $2 ]; then
	PromtMountFail $1 $2
	echo "mount point \"$2\" is not existed"
	return 1
fi

mount $1 $2
if test $? -ne 0; then
	PromtMountFail $1 $2
else
	echo "mount \"$1\" to \"$2\" success"
fi

DeviceNode=""
MountPoint=""
echo
}

# Mount /dev/sda3 to /home/sunrise/workspace
DeviceNode="/dev/sda3"
MountPoint="/home/sunrise/workspace"
MountDevice $DeviceNode $MountPoint

# You can add mount device 
