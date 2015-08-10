#!/bin/sh
WiFiSetFile=/opt/wifi/setting/WiFi.dat

WiFiModuleName=''
WiFiMode=''
WiFiDName=''
KERNEL_VERSION=`uname -r`

#############################################################################################
# switch WiFi Mode(AP/STA)
echo -e "****** Switch WiFi Mode(AP/STA)"
WiFiDName="$(readwifi.sh ${WiFiSetFile} WiFi_DName)"
ifconfig | grep "$WiFi_DName"
if [ $? -eq 0 ]; then
	ifconfig $WiFiDName down
fi

WiFiMode="$(readwifi.sh ${WiFiSetFile} WiFi_Mode)"
WiFiModuleName="$(readwifi.sh ${WiFiSetFile} WiFi_ModuleName)"
echo "$WiFiMode aa"
echo "$WiFiModuleName aa"
if [ "$WiFiMode" = "STA" ]; then
	if [ "$WiFiModuleName" = "7601" ]; then
		modprobe -r mt7601Usta
		if [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtnet7601Uap.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/mt7601Uap.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtutil7601Uap.ko ]; then
			modprobe rtnet7601Uap
		else
			echo -e "ERROR: Don't find WiFi driver files!"
			exit 1;
		fi
	elif [ "$WiFiModuleName" = "5370" ]; then
		modprobe -r rtnet5370sta
		if [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtnet5370ap.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rt5370ap.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtutil5370ap.ko ]; then
			modprobe rtnet5370ap
		else
			echo -e "ERROR: Don't find WiFi driver files!"
			exit 1;
		fi
	fi
	
	WiFiMode=AP
	updatewifi.sh  ${WiFiSetFile} WiFi_Mode $WiFiMode
elif [ "$WiFiMode" = "AP" ] ; then
	if [ "$WiFiModuleName" = "7601" ]; then
		modprobe -r rtnet7601Uap
		if [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/mt7601Usta.ko ]; then
				modprobe mt7601Usta
		else
			echo -e "ERROR: Don't find WiFi driver files!"
			exit 1;
		fi
	elif [ "$WiFiModuleName" = "5370" ]; then
		modprobe -r rtnet5370ap
		if [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtnet5370sta.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rt5370sta.ko ] && 
			 [ -f /usr/lib/modules/$KERNEL_VERSION/net/wireless/rtutil5370sta.ko ]; then
			modprobe rtnet5370sta
		else
			echo -e "ERROR: Don't find WiFi driver files!"
			exit 1;
		fi
	fi
	
	WiFiMode=STA
	updatewifi.sh  ${WiFiSetFile} WiFi_Mode $WiFiMode
fi

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
