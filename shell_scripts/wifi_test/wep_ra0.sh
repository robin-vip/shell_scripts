#!/bin/sh
echo " set ra0 "

ifconfig ra0 up
iwpriv ra0 get_site_survey

iwpriv ra0 set AuthMode=WEPAUTO
iwpriv ra0 set NetworkType=Infra
iwpriv ra0 set EncrypType=WEP

#********************set wep key*********************
echo -n "KeyID="
read KeyID
iwpriv ra0 set DefaultKeyID=$KeyID
echo -n "KeyString="
read KeyString
iwpriv ra0 set Key$KeyID=$KeyString

iwpriv ra0 set SSID=eagletest


# **********************set ip address****************
echo -n "ip="
read IpAddr
if [ ${#IpAddr} = '0' ]
then udhcpc -i ra0	
else ifconfig ra0 $IpAddr
fi

iwpriv ra0 connStatus	

