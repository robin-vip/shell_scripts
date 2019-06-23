#!/bin/sh

Interface=ra0
DHCP_ENABLE=true
IP=""
log=/tmp/wifi.log

SSID=$1
Password=$2

para_num=$#

usage() {
	echo "Usage: wifi_key_verify SSID [Password]"
	echo
}

if [ $para_num -lt 1 ] || [ $para_num -gt 2 ]
then
	usage
	exit 1;
fi

ifconfig $Interface up

count=$(ps -ef | grep -c wpa_supplicant)
if [ "$count" = "1" ]; then
		wpa_supplicant -Dwext -i$Interface -c /etc/wpa_supplicant.conf -B | tee -a $log
		run_time=1
		sleep 2
fi

if [ $para_num -eq 1 ]; then
	echo -n "Please input $SSID's Password: "
	read Password
fi

start_wifi_module() {
	ifconfig | grep -q "${Interface}"
	if [ $? -ne 0 ] ; then
		ifconfig $Interface up
		usleep 10000
	fi
}

# OPEN/NONE
set_OPEN_NONE() {
	wpa_cli -i$Interface -p/var/run/wpa_supplicant remove_network 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant ap_scan 1
	wpa_cli -i$Interface -p/var/run/wpa_supplicant add_network 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 ssid "\"$SSID\""
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 key_mgmt NONE
	wpa_cli -i$Interface -p/var/run/wpa_supplicant select_network 0
}

# SHARED/WEP
set_SHARED_WEP() {
	wpa_cli -i$Interface -p/var/run/wpa_supplicant remove_network 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant add_network 0
#	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 ssid "\"$SSID\""
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 key_mgmt NONE
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 wep_key0 "$Password"
#	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 wep_key0 "\"$Password\""
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 wep_tx_keyidx 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 auth_alg SHARED
#	wpa_cli -i$Interface -p/var/run/wpa_supplicant enable_network 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant select_network 0
	wpa_cli -i$Interface -p /var/run/wpa_supplicant status
}

# OPEN/WEP
set_OPEN_WEP() {
	wpa_cli -i$Interface -p/var/run/wpa_supplicant remove_network 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant ap_scan 1
	wpa_cli -i$Interface -p/var/run/wpa_supplicant add_network 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 ssid "$SSID"
#	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 ssid "\"$SSID\""
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 key_mgmt NONE
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 wep_key0 "$Password"
#	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 wep_key0 "\"$Password\""
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 wep_tx_keyidx 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant select_network 0
}

# TKIP/AES
set_TKIP_AES()
{
	wpa_cli -i$Interface -p/var/run/wpa_supplicant remove_network 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant ap_scan 1
	wpa_cli -i$Interface -p/var/run/wpa_supplicant add_network 0
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 ssid "\"$SSID\""
	wpa_cli -i$Interface -p/var/run/wpa_supplicant set_network 0 psk "\"$Password\""
	wpa_cli -i$Interface -p/var/run/wpa_supplicant select_network 0
}

get_connect_status() {
	if [ "$DHCP_ENABLE" = "true" ]; then
		udhcpc -i $Interface -n -t 9;
	else
		echo -n "Please input IP: "
		read IP
		ifconfig $Interface $IP
	fi
	
	wpa_cli -i$Interface -p/var/run/wpa_supplicant status
	wpa_cli -i$Interface -p/var/run/wpa_supplicant status | grep -q "COMPLETED"
	if [ $? -ne 0 ] ; then
		echo
		echo "################## Failed to connect AP ########################"
		echo "SSID=$SSID, Password=$Password"
		echo "################################################################"
		echo
		return 1
	else
		echo
		echo "################ Successed to connect AP #######################"
		echo "SSID=$SSID, Password=$Password"
		echo "################################################################"
		echo
		return 0
	fi
}


connect_AP() {
	wpa_cli -i$Interface -p/var/run/wpa_supplicant scan

	if [ "$run_time" = "1" ]; then
		sleep 5
	fi
	usleep 10000

	AuthMode_EN=$(wpa_cli -i$Interface -p/var/run/wpa_supplicant scan_results | grep "$SSID" | awk '{printf $4 "\n"}')
	echo
	echo "AuthMode_EN=$AuthMode_EN"
	if [ "$AuthMode_EN" = "[ESS]" ]; then
		set_OPEN_NONE
		return
	fi
	
	if [ "$AuthMode_EN" = "[WPS][ESS]" ]; then
		set_OPEN_NONE
		return
	fi
	
	if [ "$AuthMode_EN" = "[WEP][ESS]" ]; then
		set_OPEN_WEP
		#set_SHARED_WEP
		return
	fi
	
	echo $AuthMode_EN | grep -q "\-PSK\-"
	if [ "$?" = "0" ]; then
		set_TKIP_AES
		return
	fi

	echo "Sorry, can not support $AuthMode_EN"
	exit 1;
}

start_wifi_module
connect_AP
get_connect_status

