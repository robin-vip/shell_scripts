#!/bin/sh

Interface=ra0
DHCP_ENABLE=true
IP=""

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

#iwpriv $Interface get_site_survey
iwpriv $Interface get_site_survey | grep "${SSID}"
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
	iwpriv $Interface set NetworkType=Infra
	iwpriv $Interface set AuthMode=OPEN
	iwpriv $Interface set EncrypType=NONE
	iwpriv $Interface set SSID=$SSID
}

# SHARED/WEP
set_SHARED_WEP() {
	iwpriv $Interface set NetworkType=Infra
	iwpriv $Interface set AuthMode=SHARED
	iwpriv $Interface set EncrypType=WEP
	iwpriv $Interface set IEEE8021X=0
	iwpriv $Interface set Key1=$Password
	iwpriv $Interface set DefaultKeyID=1
	iwpriv $Interface set SSID=$SSID
}

# OPEN/WEP
set_OPEN_WEP() {
	iwpriv $Interface set NetworkType=Infra
	iwpriv $Interface set AuthMode=OPEN
	iwpriv $Interface set EncrypType=WEP
	iwpriv $Interface set IEEE8021X=0
	iwpriv $Interface set Key1=$Password
	iwpriv $Interface set DefaultKeyID=1
	iwpriv $Interface set SSID=$SSID
}

# WPAPSK/TKIP
set_WPAPSK_TKIP() {
	iwpriv $Interface set NetworkType=Infra
	iwpriv $Interface set AuthMode=WPAPSK
	iwpriv $Interface set EncrypType=TKIP
	iwpriv $Interface set IEEE8021X=0
	iwpriv $Interface set SSID=$SSID
	iwpriv $Interface set WPAPSK=$Password
	iwpriv $Interface set DefaultKeyID=2
	iwpriv $Interface set SSID=$SSID
}

# WPAPSK/AES
set_WPAPSK_AES() {
	iwpriv $Interface set NetworkType=Infra
	iwpriv $Interface set AuthMode=WPAPSK
	iwpriv $Interface set EncrypType=AES
	iwpriv $Interface set IEEE8021X=0
	iwpriv $Interface set SSID=$SSID
	iwpriv $Interface set WPAPSK=$Password
	iwpriv $Interface set DefaultKeyID=2
	iwpriv $Interface set SSID=$SSID
}

# WPA2PSK/AES
set_WPA2PSK_AES() {
	iwpriv $Interface set NetworkType=Infra
	iwpriv $Interface set AuthMode=WPA2PSK
	iwpriv $Interface set EncrypType=AES
	iwpriv $Interface set IEEE8021X=0
	iwpriv $Interface set SSID=$SSID
	iwpriv $Interface set WPAPSK=$Password
	iwpriv $Interface set DefaultKeyID=2
	iwpriv $Interface set SSID=$SSID
}

# WPA2PSK/TKIP
set_WPA2PSK_TKIP() {
	iwpriv $Interface set NetworkType=Infra
	iwpriv $Interface set AuthMode=WPA2PSK
	iwpriv $Interface set EncrypType=TKIP
	iwpriv $Interface set IEEE8021X=0
	iwpriv $Interface set SSID=$SSID
	iwpriv $Interface set WPAPSK=$Password
	iwpriv $Interface set DefaultKeyID=2
	iwpriv $Interface set SSID=$SSID
}

get_connect_status() {
	if [ "$DHCP_ENABLE" = "true" ]; then
		udhcpc -i $Interface -n -t 6;
	else
		echo -n "Please input IP: "
		read IP
		ifconfig $Interface $IP
	fi
	
	iwpriv $Interface connStatus
	iwpriv $Interface connStatus | grep -q "Connected"
	if [ $? -ne 0 ] ; then
		echo "SSID=$SSID, Password=$Password"
	fi
}


connect_AP() {
	AuthMode_EN=$(iwpriv $Interface get_site_survey | grep "$SSID" | awk '{printf $4 "\n"}')
	if [ "$AuthMode_EN" = "WPA2PSK/TKIP" ] || [ "$AuthMode_EN" = "WPA1PSKWPA2PSK/TKIP" ]
	then
		set_WPA2PSK_TKIP
	elif [ "$AuthMode_EN" = "WPAPSK/TKIP" ]
	then
		set_WPAPSK_TKIP
	
	elif [ "$AuthMode_EN" = "WPA2PSK/AES" ] || [ "$AuthMode_EN" = "WPA1PSKWPA2PSK/AES" ]
	then
		set_WPA2PSK_AES
	
	elif [ "$AuthMode_EN" = "WPAPSK/AES" ]
	then
		set_WPAPSK_AES
		
	elif [ "$AuthMode_EN" = "WEP" ]
	then
		set_SHARED_WEP
	
	elif [ "$AuthMode_EN" = "NONE" ]
	then
		set_OPEN_NONE
			
	else
		echo "Sorry, don't support $AuthMode_EN"
		exit 1;
	fi
}

start_wifi_module
connect_AP
get_connect_status

