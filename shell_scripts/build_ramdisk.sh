#!/bin/sh
# Create ramdisk file system
# Date: 2014/03/07 Written by Ward
# Version: v1.00(inital)
# Modify: v1.01 add create time for file name

create_time=$(date +%Y%m%d)
ramfs_name="did5306_$create_time.ramfs.gz"


#**************************del some files, example: ramdisk.gz $ramfs_name ramdisk**************************
if [ -f ./ramdisk ]
then
	rm ./ramdisk
fi

if [ -f ramdisk.gz ]
then
 rm ./ramdisk.gz
fi

if [ -f $ramfs_name ]
then
	rm ./$ramfs_name
fi
#**********************************************end******************************************

echo
echo ********************************create file: ramdisk*************************
echo creating...
dd if=/dev/zero of=./ramdisk bs=1M count=30

echo "format file"
mkfs.ext2 -F ramdisk
echo **************************************end************************************
echo

if [ -d /mnt/initrd ]
then
	echo "Directory /mnt/initrd is exists"
else
	mkdir -p /mnt/initrd
fi

# ************************Check directory "/mnt/initrd" is null.*******************
if [ $(ls /mnt/initrd | wc -l) != 0 ]
then
	umount /mnt/initrd
else
	echo "/mnt/initrd/ is null directory"
fi
#***************************************end*****************************************

echo ************************************mount device*****************************
echo mounting...
mount -o loop ramdisk /mnt/initrd
echo ****************************************end***********************************
echo

echo ***********************************copy files system**************************
echo copying...
cp -fra ./rootfs.rd/* /mnt/initrd
echo **************************************end*************************************
echo

echo ************************************umount device*****************************
echo umounting...
umount ramdisk
echo *****************************************end***********************************
echo

echo ************************creat ramdisk.gz $ramfs_name******************
echo creating...
gzip -v9 ramdisk
./mkimage -n 'uboot ext2 ramdisk rootfs' -A arm -O linux -T ramdisk -C none -a 0x10000000 -e 0x10000040 -d ramdisk.gz $ramfs_name 
echo *******************************************end*********************************
echo

echo finish!!
echo
