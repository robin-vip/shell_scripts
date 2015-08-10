#!/bin/sh
# Function: Create a filesystem based on emmc
# History:    
#           v1.00(inital) 07/18/2014 Created by ward

# Check file's existence.
check_file_existence(){
file_name=$1
ls $file_name >> /tmp/build_emmc_fs.log
if test $? -ne 0; then
    echo -e "      File: \"$file_name\" is not exist!!" >> /tmp/build_emmc_fs.log
    return 1
else
    echo -e "      File: \"$file_name\" is exist" >> /tmp/build_emmc_fs.log
    return 0    
fi
}

# Check emmc device existence.
check_emmc_device_existence(){
check_file_existence /dev/mmcblk0
if test $? -ne 0; then
    echo -e "      emmc device is not exist!!"
    exit 1
else
    echo -e "      emmc device is exist"    
fi
}

# Check first partions existence
check_first_partioin_existence(){
check_file_existence /dev/mmcblk0p1
if test $? -ne 0; then
    echo -e "      /dev/mmcblk0p1 partion is not exist!!"
    existence_partion1=false
else
    echo -e "      /dev/mmcblk0p1 partion is exist"
    existence_partion1=true    
fi
}

# Check second partions existence
check_second_partioin_existence(){
check_file_existence /dev/mmcblk0p2
if test $? -ne 0; then
    echo -e "      /dev/mmcblk0p2 partion is not exist!!"
    existence_partion2=false
else
    echo -e "      /dev/mmcblk0p2 partion is exist"
    existence_partion2=true    
fi
}

# Format partion
format_partion(){
partion_num=$1
filesystem_type=$2
mkfs.$filesystem_type $partion_num >> /tmp/build_emmc_fs.log
}

# Get per partion's mount point and umount those mount point
umount_emmc_partions(){
tmp_file=/tmp/tmp_build_emmc_fs.txt
existence_partion1=$1
existence_partion2=$2

df -h > $tmp_file

if [ "$existence_partion1" == "true" ]; then
    cmd_result=$(cat $tmp_file | grep mmcblk0p1;);
    mount_point=$(echo $cmd_result | cut -d '%' -f 2;)
    if [ "$mount_point" != "" ]; then
        umount $mount_point
    fi
fi    

if [ "$existence_partion2" == "true" ]; then
    cmd_result=$(cat $tmp_file | grep mmcblk0p2;)
    mount_point=$(echo $cmd_result | cut -d '%' -f 2;)
    if [ "$mount_point" != "" ]; then
        umount $mount_point
    fi
fi
}

# Umount The usb stick device.
umount_usb_stick(){
tmp_file=/tmp/tmp_build_emmc_fs.txt
usb_stick=$1
df -h > $tmp_file

cmd_result=$(cat $tmp_file | grep $usb_stick;)
mount_point=$(echo $cmd_result | cut -d '%' -f 2;)
if [ "$mount_point" != "" ]; then
    umount $mount_point
fi
}

# Get per partion's filesystem type
get_partion_fs_type(){
blkid > $tmp_file
cmd_result=$(cat $tmp_file | grep /dev/mmcblk0p1;)
cmd_result=$(echo $cmd_result | cut -d '"' -f 4;)
#echo -e "      The first partion's format is \"$cmd_result\""
if [ "$cmd_result" == "vfat" ]; then
    format_partion1=vfat
else
    format_partion1=other
fi    

cmd_result=$(cat $tmp_file | grep /dev/mmcblk0p2;)
cmd_result=$(echo $cmd_result | cut -d '"' -f 4;)
#echo -e "      The second partion's format is \"$cmd_result\""
if [ "$cmd_result" == "ext2" ]; then
    format_partion2=ext2
else
    format_partion2=other
fi
}

clear
echo -e "##################################################################"
echo -e "#                                                                #"
echo -e "#                 Create EXT2 filesystem based on emmc           #"
echo -e "#                       version: v1.00 Date: 07/18/2014          #"
echo -e "##################################################################"
echo -e
echo -e "      First emmc partion store kernel file:vmlinux.bin"
echo -e "      Second emmc partion store root filesystem"
echo -e
echo -e

#************************************************************************************************
echo -e
echo -e "##################################################################"
echo -e "      Check the existence of emmc device"
check_emmc_device_existence

echo -e "      Check the existence of /dev/mmcblk0p1 and /dev/mmcblk0p1 partion "
existence_partion1=false
existence_partion2=false

check_first_partioin_existence
check_second_partioin_existence
#************************************************************************************************

#echo -e
#echo -e "##################################################################"
#echo -e "      Umount emmc partions"
umount_emmc_partions $existence_partion1 $existence_partion2

#************************************************************************************************
if [ "$existence_partion1" == "false" ] || [ "$existence_partion2" == "false" ]; then
    echo -e
    echo -e "##################################################################"
    echo -e "      Create emmc partions"
    /sbin/fdisk /dev/mmcblk0 &> /dev/null <<EOF
    d
    1
    d
    
    n
    p
    1
    1
    +100M
    
    n
    p
    2
    
    
    w
EOF
fi
#************************************************************************************************

#************************************************************************************************
if [ "$existence_partion1" == "false" ] || [ "$existence_partion2" == "false" ]; then
echo -e
echo -e "##################################################################"
echo -e "      Check the existence of /dev/mmcblk0p1 and /dev/mmcblk0p1 partion "
check_first_partioin_existence
check_second_partioin_existence

if [ "$existence_partion1" == "false" ] || [ "$existence_partion2" == "false" ]; then
    echo -e "      Manual create device inode."
fi

if [ "$existence_partion1" == "false" ]; then
    mknod /dev/mmcblk0p1 b 179 1
fi

if [ "$existence_partion2" == "false" ]; then
    mknod /dev/mmcblk0p2 b 179 2
fi
fi
#************************************************************************************************

#echo -e
#echo -e "##################################################################"
#echo -e "      Umount emmc partions"
umount_emmc_partions $existence_partion1 $existence_partion2

#************************************************************************************************
format_partion1=other
format_partion2=other

get_partion_fs_type
if [ "$format_partion1" == "other" ] || [ "$format_partion2" == "other" ]; then
    echo -e
    echo -e "##################################################################"
    echo -e "      Format per partions."
fi

if [ "$format_partion1" == "other" ]; then
    format_partion /dev/mmcblk0p1 vfat
fi

if [ "$format_partion2" == "other" ]; then
    format_partion /dev/mmcblk0p2 ext2
fi
#************************************************************************************************

#************************************************************************************************
echo -e
echo -e "##################################################################"
echo -e "      Mount emmc partions to mount point"
mkdir /mnt/kernel -p
mkdir /mnt/fs -p

mount /dev/mmcblk0p1 /mnt/kernel
mount /dev/mmcblk0p2 /mnt/fs
#************************************************************************************************

#************************************************************************************************
echo -e
echo -e "##################################################################"
echo -e "      Copy vmlinux.bin and filesystem to emmc device"
usb_stick=$(ls /dev/sd??)
umount_usb_stick $usb_stick
mkdir /mnt/usb -p
mount $usb_stick /mnt/usb
cp /mnt/usb/vmlinux.bin /mnt/kernel/ -fa
sync
cd /mnt/fs
tar zxvf /mnt/usb/rootfs.tar.gz >> /tmp/build_emmc_fs.log
sync
cp /tmp/build_emmc_fs.log /mnt/usb
#************************************************************************************************

echo -e
echo -e "      Build filesystem success base on emmc device"
