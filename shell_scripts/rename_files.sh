#!/bin/sh

source_str=$1
dest_str=$2

for i in `find ./ -name "*${source_str}*"`;
do
	mv -f $i `echo $i | sed "s/${source_str}/${dest_str}/g"`
	#mv -f $i `echo $i | sed 's/bb/aa/g'`

done


