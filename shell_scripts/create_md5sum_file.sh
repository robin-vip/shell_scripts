#!/bin/sh
target_dir=$1

cd $target_dir
file_list=`ls ./`

for i in $file_list
do
	md5sum $i > $i.md5sum
done

cd -
