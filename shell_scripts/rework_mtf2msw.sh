#!/bin/sh

# erase uboot and uboot-env in nor flash.
echo 
echo "----->> erase uboot and uboot-env in nor flash."
mtd_debug erase /dev/mtd8 0x0 0x200000
if test $? -ne 0; then
	echo "Failed to erase uboot and uboot-env."
	echo 
	exit 1
fi

# write nor flash image to nor flash.
echo
echo "----->> write nor flash image to nor flash."
mtd_debug write /dev/mtd8 0x0 0x200000 did5206mSW_pm_nor_flash_img_v1.02.bin
if test $? -ne 0; then
        echo "Failed to write nor flash image to nor flash."
        echo 
        exit 1
fi

# erase nand flash partition.
echo
echo "----->> erase nand flash partition."
mtd_debug erase /dev/mtd1 0x0 0x280000
mtd_debug erase /dev/mtd2 0x0 0xb00000
mtd_debug erase /dev/mtd3 0x0 0x2800000
mtd_debug erase /dev/mtd4 0x0 0xb00000
mtd_debug erase /dev/mtd5 0x0 0xa000000
mtd_debug erase /dev/mtd6 0x0 0x1d00000
mtd_debug erase /dev/mtd7 0x0 0x10000000

echo "----->> rework OK."
