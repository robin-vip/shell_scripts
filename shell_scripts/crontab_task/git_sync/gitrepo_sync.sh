#!/bin/sh

ConfigFile=gitrepo_config.ini
LogFile="git_sync_$(date '+%Y%m').log"
ReposNum=
OLD_DIR=

PrintLog()
{
	echo "[$(date '+%Y-%m-%d %H:%M:%S')]: $1" >> $LogFile
}

InitTask()
{
	OLD_DIR=`pwd`; cd `dirname $0`
	source ../../config_parase/ini_prase.sh
	LogFile="$(GetIniKey "$ConfigFile" "Header:ConfigPath")/$LogFile"
	ReposNum=$(GetIniKey "$ConfigFile" "Header:ReposNum")
	cd $OLD_DIR
}

InitTask

Index=1
while [ $Index -le $ReposNum ]; do
	repos=$(GetIniKey "$ConfigFile" "Repos$Index:Name")
	path=$(GetIniKey "$ConfigFile" "Repos$Index:Path")

	if [ -d "$path" ]; then
		PrintLog "Start sync repos:\"$repos\"..."
		
		cd $path
		remote_num=$(git remote -v | awk '{print $1}' | uniq | wc -l)
		remote_idx=1	
		while [ $remote_idx -le $remote_num ]; do
			remote_name=$(git remote -v | awk '{print $1}' | uniq | sed -n "`echo $remote_idx`p")
			remote_url=$(git remote -v | awk '{print $2}' | uniq | sed -n "`echo $remote_idx`p")
			PrintLog "push repos:\"$repos\" to $remote_url"
			
			if [ "gogs_local" == "$remote_name" ]; then
				branch="development"
			else
				branch="master"
			fi
			
			git push $remote_name master:$branch >> $LogFile 2>&1
			echo "" >> $LogFile
			let remote_idx+=1
		done
		cd $OLD_DIR
		
		echo "" >> $LogFile
	else
		PrintLog "$path is not exist."
	fi

	let Index+=1
done
