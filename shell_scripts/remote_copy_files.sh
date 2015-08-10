#!/bin/sh
# Function:       Remote copy files via scp tools
# Author:         Ward write at 07/24/2014
# Version:        v1.00(inital)

echo -e "##################################################################################"


echo -e "##################################################################################"
echo -e "#                        Remote copy files tools                                 #"
echo -e "#                                             Versison: v1.00 07/24/2014         #"
echo -e "##################################################################################"
echo -e

quit=n
while [ "$quit" != "y" ]
do
read -ep "    Please input target IP address(or hostname):" target_ip
ping -c 4 $target_ip > /dev/null
if test $? -ne 0; then
    echo -e "    Target's IP or hostname is error"
else
    quit=y
fi    
done

read -ep "    Please input target machine's username:" username
read -ep "    Please input source files path:" source_path
read -t 60 -ep "    Please input files store path:" local_path

if [ "$local_path" == "" ]; then
    local_path=./
fi    

quit=n
while [ "$quit" != "y" ]
do
quit=y
read -ep "    Please input copy's direction("to" or "from"):" direction
case "$direction" in
    "to")
        scp -rv $local_path $username@$target_ip:$source_path 
        ;;
    "from")
        scp -rv $username@$target_ip:$source_path $local_path
        ;;
    *)
        echo -e "Sorry, choice not recognized"
        quit=n
esac        
done

