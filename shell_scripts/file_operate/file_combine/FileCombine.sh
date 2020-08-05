# ***************************************************************************
#  @brief       Combine files according to the config file. It depends cksfv,
#               awk, sed, dd, xxd tools.
#  @file        FileCombine.sh
#  @date        2020-07-30
#  @author      Robin
# ***************************************************************************
#!/bin/sh
show_usage () {
    echo "usage: $0 config_file"
    echo "example: $0 input/config.ini"
}

# brief         show some messages before exiting the program.
err_exit () {
    echo "Failed at line $1"
    show_usage
    exit 1
}

# brief         Get CRC32 literal value with cksfv tool.
# param[in]     file name.
# param[out]    CRC32 literal string value.
crc32 () {
    file_name=$1
    echo -n `cksfv $file_name | grep "$file_name " | awk '{split($0,a," "); print a[2]}'`
}

# brief         Get file size.
# param[in]     file name.
# param[out]    file size with hex literal string value.
get_filesize() {
    file_name=$1
    file_size=`ls -l $file_name | awk '{split($0,a," "); print a[5]}'`
    file_size=`printf "%08X" $file_size`
    echo -n $file_size
}

# brief         Write file data to destination file to the given position. 
#               write_file source_file dest_file offset
# param[in]     the source file name.
# param[in]     the destination file name.
# param[in]     the data size to be written.
# param[in]     The offset of to be written into destination file.
write_file() {
    source_file=$1
    dest_file=$2
    file_size=$3
    offset=$4
    # Convert offset to decimal digit from hex.
    offset=`printf "%d" $offset`
#    dd if=$source_file of=$dest_file bs=$file_size count=1 seek=$offset > /dev/null 2>&1
    dd if=$source_file of=$dest_file bs=1 count=$file_size seek=$offset 
}

# brief         Write hex string value to binary file with the given offset.
# param[in]     hex string.
# param[in]     the destination binary file.
# param[in]     the offset of to be written into destination file.
write_hex_str_to_bin_file() {
    hex_str=$1
    dest_file=$2
    offset=$3
    echo -n "$hex_str" | xxd -r -ps > temp.bin
    file_size=$(get_filesize temp.bin)
#echo "file_size: $file_size"
    dd if=temp.bin of=$dest_file bs=1 count=$file_size seek=$offset > /dev/null 2>&1
#dd if=temp.bin of=$dest_file bs=1 count=$file_size seek=$offset
    rm temp.bin
}

# brief         Padding 0xFF to the file.
# param[in]     file name.
# param[in]     the start address of to be padding.
# param[in]     size.
padding_0xFF_to_file() {
    dest_file=$1
    offset=$2
    size=$3
# Generate the temp file that just includes 0xFF.
:<<!
    temp_size=0
    while [ $temp_size -lt $size ]; do
        echo -e '\0377\c' >> temp.bin
        let temp_size+=1
    done
!
    dd if=/dev/zero of=temp_zero.bin bs=$size count=1 seek=0
    tr '\0' '\377\c' < temp_zero.bin > temp.bin
    
# combine the temp file to destination file.
    dd if=temp.bin of=$dest_file bs=1 count=$size seek=$offset 
    rm temp.bin temp_zero.bin
}

# brief         Get the key value of [section:key] (ini configure file).
# param[in]     IniFile $section:$key
# return        key value on success, null string otherwise.
GetIniKey()
{
    inifile="$1"
    section=$(echo $2 | cut -d ':' -f1)
    key=$(echo $2 | cut -d ':' -f2)
    
    # ini file not exist.
    if [ -z $inifile ] || [ ! -f $inifile ]; then
    	echo ""
    	return 1
    fi
    
    # section is NULL string.
    if [ -z $section ]; then
    	echo ""
    	return 1
    fi
    
    # key is NULL string.
    if [ -z $key ]; then
    	echo ""
    	return 1
    fi
    
    sed -n "/\[$section\]/,/\[.*\]/{
    /^\[.*\]/d
    /^[ \t]*$/d
    /^$/d
    /^#.*$/d
    s/^[ \t]*$key[ \t]*=[ \t]*\(.*\)[ \t]*/\1/p
    }" $inifile | sed 's/#.*$//g' | sed 's/[ \t]*$//g'
    
    return 0
}

IniFile=$1
FileNum=
FileDirPath=
OutputCombFile=combined.bin
# brief         parase ini config file header.
# param[in]     ini config name.
parase_config_header() {
    file_name=$1
    FileNum=$(GetIniKey "$file_name" "Header:FileNum")
}

# Check input
if [ $# -ne 1 ]; then
    echo "parameter error!!!"
    show_usage
    exit 1
fi

# Start working.
echo "Start working..."
FileDirPath=`dirname $IniFile`
parase_config_header $IniFile
echo "FileNum:$FileNum"
echo "FileDirPath:$FileDirPath"

# combine images to the destination file.
Index=1
while [ $Index -le $FileNum ]; do
    m_file_name="$FileDirPath/$(GetIniKey "$IniFile" "File$Index:Name")"
    m_offset=$(GetIniKey "$IniFile" "File$Index:Offset")
    m_size=$(GetIniKey "$IniFile" "File$Index:Size")
    m_file_size=$(get_filesize $m_file_name)
    m_is_check_header=$(GetIniKey "$IniFile" "File$Index:FileCheckHeader")
    echo "File$Index Name: $m_file_name"
    echo "File$Index Offset: $m_offset"
    echo "File$Index Size: $m_size"
    echo "File$Index FileSize: 0x$m_file_size"
    echo "File$Index IsCheckHeader: $m_is_check_header"

    m_offset=`printf "%d" $m_offset`
    m_size=`printf "%d" $m_size`

    printf "file_size:%#X, size:%#X.\n" 0x$m_file_size $m_size
    if [ "$m_is_check_header" == "yes" ] || [ "$m_is_check_header" == "Yes" ] || [ "$m_is_check_header" == "YES" ]; then
        crc32_val=$(crc32 $m_file_name)
        echo "file_size: $m_file_size"
        echo "crc32_val: $crc32_val"

        write_hex_str_to_bin_file $m_file_size $OutputCombFile $m_offset
        let m_offset+=4
        write_hex_str_to_bin_file $crc32_val $OutputCombFile $m_offset
        let m_offset+=4
        
# exclude the 8 bytes image header.
        let m_size=($m_size - 8)
    fi
    
    m_file_size=`printf "%d" 0x$m_file_size`
    echo "file_size:$m_file_size  size:$m_size offset:$m_offset"
    write_file $m_file_name $OutputCombFile $m_file_size $m_offset

# Need padding the 0xFF to areas not covered by the images.
    echo "file_size:$m_file_size  size:$m_size"
    if [ $m_file_size -lt $m_size ]; then
        let m_offset+=$m_file_size
        printf "padding offset:%#x.\n" $m_offset
        let m_padding_size=($m_size - $m_file_size)
        echo "m_padding_size:$m_padding_size"
        padding_0xFF_to_file $OutputCombFile $m_offset $m_padding_size
    fi

    echo ""
    let Index+=1
done
exit 0
