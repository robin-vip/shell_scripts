#!/bin/sh
WiFiSetFile=/opt/wifi/setting/WiFi.dat

WiFiModuleName=''
WiFiMode=''
WiFiDName=''
KERNEL_VERSION=`uname -r`

#############################################################################################
# Find Module name.
echo -e "****** Find Module name."
lsusb

lsusb | grep 7601
if [ $? -eq 0 ] ; then
	WiFiModuleName=7601
else
	lsusb | grep 5370
	if [ $? -eq 0 ] ; then
		WiFiModuleName=5370
	fi
fi

if [ -z $WiFiModuleName ] ; then
	echo "ERROR: WiFiModuleName is null!"
	exit 1;
fi

updatewifi.sh  ${WiFiSetFile} WiFi_ModuleName $WiFiModuleName

#############################################################################################
# insmod WIFI module drivers.
echo -e "****** insmod WIFI module drivers."
depmod
WiFiMode="$(readwifi.sh ${WiFiSetFile} WIFI_MODE)"
if [ "$WiFiMode" = "STA" ]; then
	echo $WiFiModuleName
	if [ "$WiFiModuleName" = "7601" ]; then
		#insmod some driver modules
		if [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/mt7601Usta.ko ]; then
				modprobe mt7601Usta
		else
			echo -e "ERROR: Don't find WiFi driver files!"
			exit 1;
		fi
	elif [ "${WiFiModuleName}" = "5370" ] ; then
		#insmod some driver modules
		if [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtnet5370sta.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rt5370sta.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtutil5370sta.ko ]; then
			modprobe rtnet5370sta
		else
			echo -e "ERROR: Don't find WiFi driver files!"
			exit 1;
		fi
	else
		echo -e "ERROR: insmod WIFI modules failed!"
		exit 1;
	fi
elif [ "$WiFiMode" = "AP" ] ; then
	if [ "$WiFiModuleName" = "7601" ] ; then
		#insmod some driver modules
		if [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtnet7601Uap.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/mt7601Uap.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtutil7601Uap.ko ]; then
			modprobe rtnet7601Uap
		else
			echo -e "ERROR: Don't find WiFi driver files!"
			exit 1;
		fi
	elif [ "$WiFiModuleName" = "5370" ] ; then
		#insmod some driver modules
		if [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtnet5370ap.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rt5370ap.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtutil5370ap.ko ]; then
			modprobe rtnet5370ap
		else
			echo -e "ERROR: Don't find WiFi driver files!"
			exit 1;
		fi
	else
		echo -e "ERROR: insmod WIFI modules failed!"
		exit 1;
	fi
else
	echo -e "ERROR: WIFI_MODE is invalid in WIFI setting file!"
	exit 1;
fi

#############################################################################################
# Find WIFI device name.
echo -e "****** Find WIFI device name."
iwconfig > /tmp/wifi_test.temp 2>&1
grep "ra0" /tmp/wifi_test.temp > /dev/null
if [ $? -eq 0 ] ; then
	echo -e "SoftAP device name is ra0"
	WiFiDName=ra0
else
	grep "wlan0" /tmp/wifi_test.temp > /dev/null
	if [ $? -eq 0 ] ; then
		echo -e "SoftAP device name is wlan0"
		WiFiDName=wlan0
	else
		echo -e "ERROR: Don't found device name!"
		exit 1;
	fi
fi

updatewifi.sh  ${WiFiSetFile} WiFi_DName $WiFiDName

ifconfig $WiFiDName up