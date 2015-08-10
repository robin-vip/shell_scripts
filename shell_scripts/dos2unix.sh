#!/bin/sh
# function:	convert text files with DOS line breaks to Unix line breaks.
# author:	sunrise
# data:		07/08/2014
# version:	inital

source_file=$1
dest_file=$2

if [ "$dest_file" = "" ]; then
	dest_file=$source_file
fi

if [ ! -e $source_file ]; then
	echo "$source_file is not exsit"
fi

echo "dos2unix: converting file $source_file to UNIX format"
cat $source_file | tr -d '\r' > ${dest_file}_noM
cp ${dest_file}_noM $dest_file
rm ${dest_file}_noM

