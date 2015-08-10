#!/bin/sh
# read setting file

dest_file=$1
dest_str=$2

dest_var=`grep "$dest_str" "$dest_file" | cut -d '=' -f 2`
echo $dest_var

