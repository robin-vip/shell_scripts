#!/bin/sh
# function: Test the SoftAP functionality and performance
# History:
#              v1.00(inital) 07/17/2014 Create by Ward
#              v1.01 07/29/2014 added by Ward: 
#                             1. Set the routing table.
#                             2. imporve passwd test.


output_test_content(){
clear
echo -e "##########################################################"
echo -e "#                                                        #"
echo -e "#                 SoftAP Test Tools                      #"
echo -e "#                       version: v1.01 Date: 07/29/2014  #"
echo -e "##########################################################"

echo -e
echo -e "##########################################################"
echo -e 
echo -e "      1.Throughput Test"
echo -e "      2.SSID Test"
echo -e "      3.Passwd Test"
echo -e "      4.AuthMode and EncrypType Test"
echo -e "      5.Channel Test"
echo -e "      6.Maximum number of user connections to the Test(suggestive value: 10)"
echo -e "      7.Stability test"
echo -e "      q.Exit Test program"
echo -e
}

# Start dhcp server
start_dhcp_server(){
mkdir -p /var/lib/misc/
touch /var/lib/misc/udhcpd.leases
udhcpd -fS /etc/udhcpd.conf &
}

#set route table
setting_route_table(){
ifconfig wlan0 192.168.3.1
ifconfig br0 192.168.2.133

route add -net 0.0.0.0 netmask 0.0.0.0 gw 192.168.2.1 dev br0
route add -net 192.168.3.0 netmask 255.255.255.0 gw 192.168.3.1 dev wlan0
}

bridge_ethernet_wifi(){
echo -e
echo -e "Bridge Ethernet and WiFi Start..."
ifconfig wlan0 up
brctl addbr br0
ifconfig eth0 0.0.0.0
ifconfig wlan0 0.0.0.0
brctl addif br0 eth0
brctl addif br0 wlan0
setting_route_table
}

throughput_test(){
    echo -e
    echo -e "Throughput Test Start..."
}

hide_ssid(){
echo
}

ssid_test() {
echo -e
echo -e "##########################################################"
echo -e "SSID Test Start..."
echo -e "Test environment: AutoMode/EncrypType=WPAPSK/TKIP"
echo -e "                  passwd=1234567890"
read -p "Please input SSID:" SSID

#read -p "Hide SSID(y/n):" hide
#if [ "$hide"  == "y" ]; then
#    hide_ssid
#fi    
    
iwpriv wlan0 set AuthMode=WPAPSK
iwpriv wlan0 set EncrypType=TKIP
iwpriv wlan0 set IEEE8021X=0
iwpriv wlan0 set SSID=$SSID
iwpriv wlan0 set WPAPSK=1234567890
iwpriv wlan0 set DefaultKeyID=2
iwpriv wlan0 set SSID=$SSID
}

passwd_test() {
echo -e
echo -e "##########################################################"    
echo -e "Passwd Test Start..."
echo -e "Test environment: SSID=EKT_AP"
echo -e "SoftAP support AutoMode/EncypType:"
echo -e "               1. OPEN/WEP"
echo -e "               2. WPAPSK/TKIP"
echo -e "               3. WPAPSK/AES"
echo -e "               4. WPA2PSK/TKIP"
echo -e "               5. WPA2PSK/AES"
echo -e
read -p "Your choice(1-5):" choice
read -p "Please input passwd:" passwd

SSID=EKT_AP
quit2=n
while [ "$quit2" != "y" ]
do
quit2=y
case "$choice" in
    "1")
        iwpriv wlan0 set AuthMode=OPEN
        iwpriv wlan0 set EncrypType=WEP
        iwpriv wlan0 set IEEE8021X=0
        iwpriv wlan0 set Key1=$passwd
        iwpriv wlan0 set DefaultKeyID=1
        iwpriv wlan0 set SSID=$SSID
        ;;
    "2")
        iwpriv wlan0 set AuthMode=WPAPSK
        iwpriv wlan0 set EncrypType=TKIP
        iwpriv wlan0 set IEEE8021X=0
        iwpriv wlan0 set SSID=$SSID
        iwpriv wlan0 set WPAPSK=$passwd
        iwpriv wlan0 set DefaultKeyID=2
        iwpriv wlan0 set SSID=$SSID
        ;;
    "3")
        iwpriv wlan0 set AuthMode=WPAPSK
        iwpriv wlan0 set EncrypType=AES
        iwpriv wlan0 set IEEE8021X=0
        iwpriv wlan0 set SSID=$SSID
        iwpriv wlan0 set WPAPSK=$passwd
        iwpriv wlan0 set DefaultKeyID=2
        iwpriv wlan0 set SSID=$SSID
        ;;
    "4")
        iwpriv wlan0 set AuthMode=WPA2PSK
        iwpriv wlan0 set EncrypType=TKIP
        iwpriv wlan0 set IEEE8021X=0
        iwpriv wlan0 set SSID=$SSID
        iwpriv wlan0 set WPAPSK=$passwd
        iwpriv wlan0 set DefaultKeyID=2
        iwpriv wlan0 set SSID=$SSID
        ;;
    "5")
        iwpriv wlan0 set AuthMode=WPA2PSK
        iwpriv wlan0 set EncrypType=AES
        iwpriv wlan0 set IEEE8021X=0
        iwpriv wlan0 set SSID=$SSID
        iwpriv wlan0 set WPAPSK=$passwd
        iwpriv wlan0 set DefaultKeyID=2
        iwpriv wlan0 set SSID=$SSID
        ;;
    *)
        echo -e "      Sorry, choice not recognized. So, plese choose again"
        quit2=n
        ;;   
esac
done
}

authmode_encryptype_test(){
quit2=n
while [ "$quit2" != "y" ]
do
quit2=y
echo -e
echo -e "##########################################################"
echo -e "AuthMode and EncrypType Test Start..."
echo -e "Test environment: SSID=EKT_AP, Passwd=1234567890"
echo -e "SoftAP support AutoMode/EncypType:"
echo -e "               1. OPEN/NONE"
echo -e "               2. OPEN/WEP"
echo -e "               3. WPAPSK/TKIP"
echo -e "               4. WPAPSK/AES"
echo -e "               5. WPA2PSK/TKIP"
echo -e "               6. WPA2PSK/AES"

choice=0

read -p "               Your choice(1-6):" choice
case "$choice" in
    "1")
        AuthMode=OPEN
        EncrypType=NONE
        ;;
    "2")
        AuthMode=OPEN
        EncrypType=WEP
        ;;
    "3")
        AuthMode=WPAPSK
        EncrypType=TKIP
        ;;
    "4")
        AuthMode=WPAPSK
        EncrypType=AES
        ;;
    "5")
        AuthMode=WPA2PSK
        EncrypType=TKIP
        ;;
    "6")
        AuthMode=WPA2PSK
        EncrypType=AES
        ;;
    *)
        echo -e "      Sorry, choice not recognized. So, plese choose again"
        quit2=n
        ;;   
esac
done

Passwd=1234567890
SSID=EKT_AP

# To convert lowercase to uppercase
AuthMode=$(echo $AuthMode | tr tr '[a-z]' '[A-Z]')
EncrypType=$(echo $EncrypType | tr tr '[a-z]' '[A-Z]')

case "$AuthMode" in
    "OPEN" | "open")
        case "$EncrypType" in
            "NONE" | "none")
                iwpriv wlan0 set AuthMode=OPEN
                iwpriv wlan0 set EncrypType=NONE
                iwpriv wlan0 set IEEE8021X=0
                iwpriv wlan0 set SSID=$SSID
                ;;
            "WEP" | "wep")
                iwpriv wlan0 set AuthMode=OPEN
                iwpriv wlan0 set EncrypType=WEP
                iwpriv wlan0 set IEEE8021X=0
                iwpriv wlan0 set Key1=$Passwd
                iwpriv wlan0 set DefaultKeyID=1
                iwpriv wlan0 set SSID=$SSID
                ;;
            *)
                echo -e "Soryy, now this module doesn't support \"$EncrypType\""
                ;;
        esac
        ;;
    "WPAPSK" | "wpapsk")
        case "$EncrypType" in
            "TKIP")
                iwpriv wlan0 set AuthMode=WPAPSK
                iwpriv wlan0 set EncrypType=TKIP
                iwpriv wlan0 set IEEE8021X=0
                iwpriv wlan0 set SSID=$SSID
                iwpriv wlan0 set WPAPSK=$Passwd
                iwpriv wlan0 set DefaultKeyID=2
                iwpriv wlan0 set SSID=$SSID
                ;;
            "AES")
                iwpriv wlan0 set AuthMode=WPAPSK
                iwpriv wlan0 set EncrypType=AES
                iwpriv wlan0 set IEEE8021X=0
                iwpriv wlan0 set SSID=$SSID
                iwpriv wlan0 set WPAPSK=$Passwd
                iwpriv wlan0 set DefaultKeyID=2
                iwpriv wlan0 set SSID=$SSID
                ;;
            *)
                echo -e "Soryy, now this module doesn't support \"$EncrypType\""
                ;;
        esac
        ;;
    "WPA2PSK" | "wpa2psk")
        case "$EncrypType" in
            "TKIP")
                iwpriv wlan0 set AuthMode=WPA2PSK
                iwpriv wlan0 set EncrypType=TKIP
                iwpriv wlan0 set IEEE8021X=0
                iwpriv wlan0 set SSID=$SSID
                iwpriv wlan0 set WPAPSK=$Passwd
                iwpriv wlan0 set DefaultKeyID=2
                iwpriv wlan0 set SSID=$SSID
                ;;
            "AES")
                iwpriv wlan0 set AuthMode=WPA2PSK
                iwpriv wlan0 set EncrypType=AES
                iwpriv wlan0 set IEEE8021X=0
                iwpriv wlan0 set SSID=$SSID
                iwpriv wlan0 set WPAPSK=$Passwd
                iwpriv wlan0 set DefaultKeyID=2
                iwpriv wlan0 set SSID=$SSID
                ;;
            *)
                echo -e "Soryy, now this module doesn't support \"$EncrypType\""
                ;;
        esac
        ;;
    *)
        echo -e "Soryy, now this module doesn't support \"$AuthMode\""
        ;;
esac    

return    
}

channel_test(){
echo -e
echo -e "##########################################################"
echo -e "Channel Test Start..."
echo -e "Test environment: AutoMode/EncrypType=WPAPSK/TKIP"
echo -e "                  SSID=EKT_AP, Passwd=1234567890"
read -p "Please input Channel(1-13):" Channel

iwpriv wlan0 set AuthMode=WPAPSK
iwpriv wlan0 set EncrypType=TKIP
iwpriv wlan0 set IEEE8021X=0
iwpriv wlan0 set SSID=EKT_AP
iwpriv wlan0 set WPAPSK=1234567890
iwpriv wlan0 set DefaultKeyID=2
iwpriv wlan0 set SSID=EKT_AP

iwpriv wlan0 set Channel=$Channel
}

MaximumUsers_test(){
echo -e
echo -e "Maximum users Test Start..."
}

stability_test(){
echo -e
echo -e "Stability Test Start..."
}


# masking some kernel output infos
echo 4 > /proc/sys/kernel/printk
#cat /proc/sys/kernel/printk

# bridge ethernet and wifi
bridge_ethernet_wifi

quit=n
while [ "$quit" != "y" ]
do
output_test_content
read -p "      Your choice(1-7):" choice
case "$choice" in 
    "1")
        throughput_test
        ;;
    "2")
        ssid_test
        ;;
    "3")
        passwd_test
        ;;
    "4")
        authmode_encryptype_test
        ;;
    "5")
        channel_test
        ;;
    "6")
        MaximumUsers_test
        ;;
    "7")
        stability_test
        ;;
    "q" | "Q")
        quit=y
        ;;
    *)
        echo -e "      Sorry, choice not recognized"
        ;;
esac

done

# restore kernel output
echo 7 > /proc/sys/kernel/printk
#cat /proc/sys/kernel/printk
