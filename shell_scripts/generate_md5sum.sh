# ***************************************************************************
#  @brief       $module_or_feature -- brief description.
#  @file        generate_md5sum.sh
#  @date        2021-07-06
#  @author      sunrise
# ***************************************************************************
#!/bin/sh
help_usage() {
    echo "usage: $0 dir_name"
    echo "example: $0 ./images"
}

# Check input
if [ $# -ne 1 ] || [ ! -d $1 ]; then
    echo "parameter error!!!"
    help_usage
    exit 1
fi

# Get file name list (exclude files with ".md5sum" as the file format).
file_list=`ls $1 | grep -v ".md5sum" | grep -v "upgrade.ini"`

for file in $file_list
do
    md5sum $1/$file | cut -d ' ' -f1 > $1/$file.md5sum
    printf "finish md5sum of file:\t$file.\n"
done