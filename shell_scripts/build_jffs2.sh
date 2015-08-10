#!/bin/sh
version=$1

mkfs.jffs2 -n -e 0x20000 -l -d ./rootfs.rd/ -o ./dcd5225_"$version"_rootfs.jffs2.nand
