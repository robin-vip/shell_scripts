#!/bin/sh
# Functon:   copy images, root filesystem and apps.
# Author:    Ward write by 07/21/2014
# Version:   v1.00(inital)

VERSION=v1.02
version_output=output

ROOTDIR=$(pwd)
COREDIR=$ROOTDIR/core-3
TARGETDIR=$ROOTDIR/install_fs/$VERSION

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
# modify for dcd5225 sdk release by allan
if [ "$TARGET_FULL_INFO" == "" ]; then
    TARGET_FULL_INFO=kronos_hw-kronos_sw-kronos-kronos_singlehd_1G-gcc-4.5.2_uclibc-retail
fi

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

echo "cp finish!!"
echo
