#!/bin/sh
echo " set ra0 "

:<<MULTILINECOMMENT
AuthMode=$1
EncrypType=$2
SSID=$3
Password=$4

echo "AuthMode=$AuthMode"
echo "EncrypType=$EncrypType"
echo "SSID=$SSID"
echo "Password=$Password"
MULTILINECOMMENT

ifconfig ra0 up
iwpriv ra0 get_site_survey

# *********************set auth mode************************
echo "please input Auth Mode"
echo -n "AuthMode="
read AuthMode
if [ ${#AuthMode} = '0' ]
then AuthMode=WPAPSK
fi
iwpriv ra0 set AuthMode=$AuthMode

# *******************set network type***********************
iwpriv ra0 set NetworkType=Infra

# *******************set encrypt type***********************
echo "please input Encrypt Type"
echo -n "EncrypType="
read EncrypType
if [ ${#EncrypType} = '0' ]
then EncrypType=TKIP
fi
iwpriv ra0 set EncrypType=$EncrypType

# **********************set password************************
echo "please input password"
echo -n "password="
read password
if [ ${#EncrypType} = '0' ]
then echo "no password"
else iwpriv ra0 set WPAPSK=$password
fi

# **********************set SSID****************************
echo "please input SSID"
echo -n "SSID="
read SSID
if [ ${#SSID} = '0' ]
then SSID=eagletest
fi
iwpriv ra0 set SSID=$SSID

sleep 3
# **********************set ip address**********************
echo "please input ip address"
echo -n "ip="
read IpAddr
if [ ${#IpAddr} = '0' ]
then udhcpc -i ra0	
else ifconfig ra0 $IpAddr
fi

iwpriv ra0 connStatus	

