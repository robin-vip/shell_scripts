#!/bin/sh

## brief:      Get the key value of [section:key] (ini configure file).
## param[in]:  IniFile $section:$key
## return:     key value on success, null string otherwise.
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

