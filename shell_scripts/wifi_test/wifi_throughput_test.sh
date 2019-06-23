#!/bin/sh

time=$1
#declare -i repeat=$2
repeat=$2
father_dir=./wifi_test/throughput
file_path=${father_dir}/${time}_${repeat}.log
file_path_temp=${file_path}_temp
file_temp=/tmp/test.log

if [ ! -d $father_dir ]; then
	mkdir -p $father_dir
fi

echo "" > $file_path_temp
#echo "***************** Start Test ************************"
echo "***************** Start Test ************************" >> $file_path_temp

echo -e "" >> $file_path_temp
while [ "$repeat" != "0" ]; do

#echo -e "\n" >> $file_path_temp

netperf -H 192.168.15.66 -l $time > $file_temp
cat $file_temp
cat $file_temp >> $file_path_temp

repeat=$((repeat-1))

echo -e "" >> $file_path_temp
done

#echo "**************** Test Finished **********************"
echo "**************** Test Finished **********************" >> $file_path_temp
echo -e "\n" >> $file_path_temp

echo "Test Result as fllow:"
cat $file_path_temp

cat $file_path_temp >> $file_path

