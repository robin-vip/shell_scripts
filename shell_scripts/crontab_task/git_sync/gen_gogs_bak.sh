# ***************************************************************************
#   @Copyright (C) 2021 Robin Cao all rights reserved.
#
#  @brief       $module_or_feature -- brief description.
#  @file        gen_gogs_bak.sh
#  @date        2021-05-09
#  @author      Robin Cao
# ***************************************************************************
#!/bin/sh
#---------------------------------------------------------------------------
LogFile="/home/sunrise/var/log/gogs_bak$(date '+%Y%m').log"

# Write message to log file.
PrintLog() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')]: $1" >> $LogFile
}

# Free storage capability.
FreeStorageCap() {
    work_path=$1
    up_size=$2
    current_size=`du -sm $work_path | awk '{print $1}'`
    while [ $current_size -ge $up_size ]; do
        del_file=`ls $work_path | head -1`
        rm ${work_path}/${del_file}
        echo "Deleted file: $del_file"
        PrintLog "Deleted file: $del_file"

        current_size=`du -sm $work_path | awk '{print $1}'`
    done
}

# Backup gogs work files.
MaxCapSize=100
SrcPath=/home/git/gogs
WorkPath=/home/sunrise/workspace/gogs_bak/gogs_work
PackName="gogs_work_`date +"%y-%m-%d"`.tar.gz"

if [ -d ${WorkPath}/gogs ]; then
    rm -fr ${WorkPath}/gogs
fi

if [ ! -d $WorkPath ]; then
    mkdir -p $WorkPath
fi

# Generate backup file.
cd $WorkPath && cp -fa $SrcPath . && tar czvf $PackName gogs && rm -fr gogs
if [ $? -ne 0 ]; then
    echo "Backup $SrcPath failed."
    PrintLog "Backup $SrcPath failed."
    exit 1
else
    echo "Backup gogs to $PackName success."
    PrintLog "Backup gogs to $PackName success."
fi

# Delete the older backup packages.
FreeStorageCap $WorkPath $MaxCapSize
#---------------------------------------------------------------------------



#---------------------------------------------------------------------------
# Backup gogs mysql data files.
MaxCapSize=500
SrcPath=/var/lib/mysql
WorkPath=/home/sunrise/workspace/gogs_bak/mysql_data
PackName="mysql_data`date +"%y-%m-%d"`.tar.gz"

if [ -d ${WorkPath}/mysql ]; then
    rm -fr ${WorkPath}/mysql
fi

if [ ! -d $WorkPath ]; then
    mkdir -p $WorkPath
fi

# Generate backup file.
cd $WorkPath && cp -fa $SrcPath . && tar czvf $PackName mysql && rm -fr mysql
if [ $? -ne 0 ]; then
    echo "Backup $SrcPath failed."
    PrintLog "Backup $SrcPath failed."
    exit 1
else
    echo "Backup mysql data to $PackName success."
    PrintLog "Backup mysql data to $PackName success."
fi

# Delete the older backup packages.
FreeStorageCap $WorkPath $MaxCapSize
#---------------------------------------------------------------------------


