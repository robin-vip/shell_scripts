#!/bin/sh

DIRECTORY_TRAGET=$1

if [ -z $DIRECTORY_TRAGET ]
then
	DIRECTORY_TRAGET="."
fi

if [ ! -d $DIRECTORY_TRAGET ]
then
	echo "Please input directory name as paramter!"
fi

for file in $(ls $DIRECTORY_TRAGET)
do
	if [ ! -d ${DIRECTORY_TRAGET}/${file} ] &&  ! echo $file | grep -q "md5sum" 
#	if [ ! -d ${DIRECTORY_TRAGET}/${file} ] &&  [[ ${file} -ne "*.md5sum$" ]]
	then
		md5sum ${DIRECTORY_TRAGET}/${file} > ${DIRECTORY_TRAGET}/${file}.md5sum
	fi
done
