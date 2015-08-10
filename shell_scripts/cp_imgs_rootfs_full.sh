#!/bin/sh
# cp "uldr", "uboot", "kernel" image and root filesystem and wifi drivers
# Date: 2014/06/12 Written by Ward
# Version: v1.00(inital)
# Modify: NO

VERSION=v1.03
version_output=output

ROOTDIR=$(pwd)
COREDIR=$ROOTDIR/core-3
TARGETDIR=$ROOTDIR/install_fs_image/$VERSION

dir_sdk_root=$(pwd)

#***************************************Create target directory********************************
echo "create target directory ..."
if [ ! -e $TARGETDIR ]; then
	mkdir -p $TARGETDIR
	if test $? -ne 0; then
		echo "mkdir -p $TARGETDIR failed"
		exit
	fi
fi	

if [ ! -e $TARGETDIR/images ]; then
	mkdir -p $TARGETDIR/images
	if test $? -ne 0; then
		echo "mkdir -p $TARGETDIR/images failed"
		exit
	fi
fi	

if [ ! -e $TARGETDIR/rootfs.tmplt ]; then
	mkdir -p $TARGETDIR/rootfs.tmplt
	if test $? -ne 0; then
		echo "mkdir -p $TARGETDIR/rootfs.tmplt failed"
		exit
	fi
fi
#**********************************************************************************************
	
#*************************************copy uldr uboot kernel***********************************
if [ -e $COREDIR/entropicsdk/sdk411/SRC/target/output/flash_bin/systems/directfb_example-$TARGET_FULL_INFO ]; then
	uldr_uboot_DIR=$COREDIR/entropicsdk/sdk411/SRC/target/output/flash_bin/systems/directfb_example-$TARGET_FULL_INFO
	elif [ -e $COREDIR/entropicsdk/sdk411/SRC/target/output/flash_bin/systems/system_test-$TARGET_FULL_INFO ]; then
		uldr_uboot_DIR=$COREDIR/entropicsdk/sdk411/SRC/target/output/flash_bin/systems/system_test-$TARGET_FULL_INFO
		else
		echo "warnning: uldr uboot kernel images didn't exsit!!"
fi

# copy uldr.bin(not padded) to install directory, this one is to be signed.
if [ -e $uldr_uboot_DIR/uldr.bin ]; then
	echo "copy uldr.bin ..."
	cp $uldr_uboot_DIR/uldr.bin $TARGETDIR/images
else
	echo "copy uldr.bin failed!!"	
fi

# copy uldr.bin.uartboot_img(padded) to install directory, this one is to be downloaded via UART.
if [ -e $uldr_uboot_DIR/uldr.bin.uartboot_img ]; then
	echo "copy uldr.bin.uartboot_img ..."
	cp $uldr_uboot_DIR/uldr.bin.uartboot_img $TARGETDIR/images
else
	echo "copy uldr.bin.uartboot_img failed!!"	
fi	

# copy u-boot
if [ -e $uldr_uboot_DIR/u-boot.bin ]; then
	echo "copy u-boot.bin ..."
	cp $uldr_uboot_DIR/u-boot.bin $TARGETDIR/images
else
	echo "copy u-boot.bin failed!!"	
fi

# copy vmlinux.bin(kernel) to install directory
vmlinux_DIR=$COREDIR/entropicsdk/sdk411/SRC/target/output/imgs/kronos
if [ -e $vmlinux_DIR/vmlinux.bin ]; then
	echo "copy vmlinux.bin ..."
	cp $vmlinux_DIR/vmlinux.bin $TARGETDIR/images
else
	echo "copy vmlinux.bin failed!!"
fi		
#**********************************************************************************************

echo
#****************************************copy root filesystem**********************************
ROOTFSDIR=$TARGETDIR/rootfs.tmplt
if [ -e $ROOTFS_TMPLT_DIR ]; then
	echo "copy root filesystem ..."
	cp $ROOTFS_TMPLT_DIR/* $ROOTFSDIR -fdr
else
	echo "copy root filesystem failed!!"
	echo "$0: Program quit, and it don't finished task!!"
	exit 1;
fi
#**********************************************************************************************

echo
#******************************************copy apps*******************************************
APPSDIR=$ROOTFS_TMPLT_DIR/../appfs-directfb_example/opt/
if [ -e $APPSDIR ]; then
	echo "copy apps ..."
	cp $APPSDIR/ $ROOTFSDIR -fdr
else
	echo "copy apps failed!!"
fi

#**********************************************************************************************

echo
#*********************************************copy wifi driver*********************************
echo "copy wifi driver *.ko file ..."
if [ ! -e $ROOTFSDIR/opt/ralink ]; then
	mkdir -p $ROOTFSDIR/opt/ralink
	if test $? -ne 0; then
		echo "mkdir -p $ROOTFSDIR/opt/ralink failed!!"
		exit 1
	fi
fi

mkdir -p $ROOTFSDIR/etc/Wireless/RT2870STA
if test $? -ne 0; then
  echo "mkdir -p $ROOTFSDIR/etc/Wireless/RT2870STA failed"
  exit 1
fi

RALINK_DRIVER_PATH=SRC/target/src/sd/os/oslinux/comps/wifi/rt5370/2011_0407_RT3070_RT3370_RT5370_RT5372_Linux_STA_V2.5.0.2_DPA
if [ -e $COREDIR/entropicsdk/sdk411/$RALINK_DRIVER_PATH/UTIL/os/linux/rtutil5370sta.ko ];then
  echo "copy rtutil5370sta.ko"
  cp $COREDIR/entropicsdk/sdk411/$RALINK_DRIVER_PATH/UTIL/os/linux/rtutil5370sta.ko $ROOTFSDIR/opt/ralink 
fi

if [ -e $COREDIR/entropicsdk/sdk411/$RALINK_DRIVER_PATH/NETIF/os/linux/rtnet5370sta.ko ];then
  echo "copy rtnet5370sta.ko"
  cp $COREDIR/entropicsdk/sdk411/$RALINK_DRIVER_PATH/NETIF/os/linux/rtnet5370sta.ko $ROOTFSDIR/opt/ralink 
fi

if [ -e $COREDIR/entropicsdk/sdk411/$RALINK_DRIVER_PATH/MODULE/os/linux/rt5370sta.ko ];then
  echo "copy rt5370sta.ko"
  cp $COREDIR/entropicsdk/sdk411/$RALINK_DRIVER_PATH/MODULE/os/linux/rt5370sta.ko $ROOTFSDIR/opt/ralink 
fi

if [ -e $COREDIR/entropicsdk/sdk411/$RALINK_DRIVER_PATH/MODULE/RT2870STA.dat ];then
  cp $COREDIR/entropicsdk/sdk411/$RALINK_DRIVER_PATH/MODULE/RT2870STA.dat $ROOTFSDIR/etc/Wireless/RT2870STA/RT5370STA.dat
fi

MT7601_DRIVER_PATH=SRC/target/src/sd/os/oslinux/comps/wifi/mt7601/DPA_MT7601U_LinuxSTA_3.0.0.3_20130313
if [ -e $COREDIR/entropicsdk/sdk411/$MT7601_DRIVER_PATH/UTIL/os/linux/mtutil7601Usta.ko ];then
  echo "copy mtutil7601Usta.ko"
  cp $COREDIR/entropicsdk/sdk411/$MT7601_DRIVER_PATH/UTIL/os/linux/mtutil7601Usta.ko $ROOTFSDIR/opt/ralink 
fi

if [ -e $COREDIR/entropicsdk/sdk411/$MT7601_DRIVER_PATH/NETIF/os/linux/mtnet7601Usta.ko ];then
  echo "copy mtnet7601Usta.ko"
  cp $COREDIR/entropicsdk/sdk411/$MT7601_DRIVER_PATH/NETIF/os/linux/mtnet7601Usta.ko $ROOTFSDIR/opt/ralink 
fi

if [ -e $COREDIR/entropicsdk/sdk411/$MT7601_DRIVER_PATH/MODULE/os/linux/mt7601Usta.ko ];then
  echo "copy mt7601Usta.ko"
  cp $COREDIR/entropicsdk/sdk411/$MT7601_DRIVER_PATH/MODULE/os/linux/mt7601Usta.ko $ROOTFSDIR/opt/ralink 
fi

if [ -e $COREDIR/entropicsdk/sdk411/$MT7601_DRIVER_PATH/MODULE/RT2870STA.dat ];then
  cp $COREDIR/entropicsdk/sdk411/$MT7601_DRIVER_PATH/MODULE/RT2870STA.dat $ROOTFSDIR/etc/Wireless/RT2870STA/MT7601STA.dat
fi
#**********************************************************************************************	

echo
#********************************************back up rootfs************************************
ROOTFSBK=$(dirname $ROOTFSDIR)/rootfs_org
mkdir -p $ROOTFSBK
if test $? -ne 0; then
	echo "mkdir -p $ROOTFSBK failed!!"
	exit 1
fi

echo "backup rootfs ..."
cp $ROOTFSDIR/* $ROOTFSBK -fdr
#**********************************************************************************************	



echo
echo "$0: finished it's work"
