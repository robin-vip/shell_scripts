#!/bin/sh
log=~/tmp/git.log

updatelocalRep()
{
	echo "" | tee -a $log
	repfolder=$1
	if [ ! -d $repfolder/.git ]; then
		echo "[$(date +"%Y-%m-%d")] $repfolder/.git is not exist!!!" | tee -a $log
		return 1
	fi
	cd $repfolder

	min_loop=1
	max_loop=10

	RepName=$(basename $repfolder)
	echo "[$(date +"%Y-%m-%d")] Updating $RepName" | tee -a $log
	while [ $min_loop -le $max_loop ]
	do
		min_loop=$((min_loop+1))
		echo "[$(date +"%k:%M:%S")] git fetching ..." | tee -a $log
		git fetch --all 2>>$log
		if [ $? -eq 0 ]; then
			echo "[$(date +"%k:%M:%S")] git fetch $RepName successfully." | tee -a $log
			echo "[$(date +"%k:%M:%S")] git pulling ..."
			git pull 2>>$log
			if [ $? -eq 0 ]; then
				echo "[$(date +"%k:%M:%S")] git pull $RepName successfully." | tee -a $log
				return 1
			else
				echo "[$(date +"%k:%M:%S")] git pull $RepName failed !!!" | tee -a $log
			fi
		else
			echo "[$(date +"%k:%M:%S")] git fetch $RepName failed !!!" | tee -a $log
		fi
		sleep 600
	done
	
	return 0
}

updatelocalRep "/home/ward/project/SDK/ali_sdk/ali_buildroot_git/ali_buildroot"
updatelocalRep "/home/ward/project/SDK/ali_sdk/build_git/"


