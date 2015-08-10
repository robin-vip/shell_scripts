#!/bin/sh
# read setting file

dest_file=$1
dest_str=$2
dest_var=$3

sed -i "s/^${dest_str}=.*$/${dest_str}=${dest_var}/g" $dest_file
