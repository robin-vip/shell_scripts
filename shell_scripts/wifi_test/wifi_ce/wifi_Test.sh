#!/bin/sh

ATETXMODE=""
ATETXBW=""
ATECHANNEL=""
ATETXPOW0=""

menu_choice=""

SetTxMode() {
echo ***********************************Setting Protocol***********************
echo "Support Protocol(0~3):"
echo "0: 802.11b,    1: 802.11g,    3: 802.11n"
echo "default setting is 3"
echo -n "Protocol="

read ATETXMODE
if [ ${#ATETXMODE} = '0' ]
then ATETXMODE=3
fi

iwpriv ra0 set ATETXMODE=$ATETXMODE

return
}

SetBandWidth() {
echo **********************************Setting BandWidth**************************
echo "Please input BandWidth. The following is a setup instructions "
echo ""
echo "0: 20Hz"
echo "1: 40Hz"

echo
echo "default setting is 0"
echo -n "ATETXBW="
read ATETXBW

if [ ${#ATETXBW} = '0' ]
then ATETXBW=0
fi

iwpriv ra0 set ATETXBW=$ATETXBW
}


SetChannel() {
echo ********************************Setting Channel******************************
echo "Please input ATECHANNEL(1~13)"

echo "default setting is 9"
echo -n "ATECHANNEL="
read ATECHANNEL

if [ ${#ATECHANNEL} = '0' ]
then ATECHANNEL=9
fi

iwpriv ra0 set ATECHANNEL=$ATECHANNEL

return
}


SetPower() {
echo ********************************Setting Output Power******************************
echo "Please input ATETXPOW0(0~31)"

echo "default setting is 18"
echo -n "ATETXPOW0="
read ATETXPOW0

if [ ${#ATETXPOW0} = '0' ]
then ATETXPOW0=18
fi

iwpriv ra0 set ATETXPOW0=$ATETXPOW0

return
}

SetPreWork() {
echo **************************************SetUP**********************************
ifconfig ra0 down
ifconfig ra0 up
clear

#iwpriv ra0 set ATE=ATESTOP
iwpriv ra0 set ATE=ATESTART
iwpriv ra0 set ATEDA=00:11:22:33:44:55
iwpriv ra0 set ATESA=00:aa:bb:cc:dd:ee
iwpriv ra0 set ATEBSSID=00:11:22:33:44:55
iwpriv ra0 set ATETXMCS=7
iwpriv ra0 set ATETXGI=0
iwpriv ra0 set ATETXLEN=1024
iwpriv ra0 set ATETXCNT=100000000
iwpriv ra0 set ATETXFREQOFFSET=32
iwpriv ra0 set ATETXANT=0

iwpriv ra0 set ATECHANNEL=9
iwpriv ra0 set ATETXPOW0=18
iwpriv ra0 set ATETXMODE=3

return
}

StartTest() {
iwpriv ra0 set ATE=TXFRAME
echo
iwpriv ra0 set ATESHOW=1
iwpriv ra0 stat

return
}

SetDataRate() {
echo ********************************set Data rate****************************
echo "Please input Data rate(0 ~ 15, 33:auto rate)"

echo "default setting is 33"
echo -n "TxRate="
read TxRate

if [ ${#TxRate} = '0' ]
then TxRate=33
fi

iwpriv ra0 set TxRate=$TxRate

return
}

SetTxMenuChoice() {
clear
echo **********************TX Mode Setting of Wi-Fi Certification Test********************
echo "Options :-"
echo "       a)    All set"
echo "       b)    Set BandWidth"
echo "       c)    Set Channel"
echo "       d)    Set DataRate"
echo "       o)    Set Output Power"
echo "       p)    Set Protocol"
echo "       r)    Restart wifi"
echo "       g)    Go Back"


echo
echo -n "menu_choice: "
read menu_choice
}

Tx_Mode() {
quit=n
while [ "$quit" != "y" ];
do
	SetTxMenuChoice
	case "$menu_choice" in
		a)
			SetPreWork;
			SetTxMode;
			SetBandWidth;
			SetDataRate;
			SetChannel;
			SetPower;
			StartTest;;
		b)
			SetPreWork;
			SetBandWidth;
			StartTest;;
		c)
			#iwpriv ra0 set ATE=ATESTOP
			#iwpriv ra0 set ATE=ATESTART
			SetPreWork;
			SetChannel;
			StartTest;;
		d)
			SetPreWork;
			SetDataRate;
			StartTest;;
		o)
			SetPower;
			StartTest;;
		p)
			SetPreWork;
			SetTxMode;
			StartTest;;
		r)
			ifconfig ra0 down
			ifconfig ra0 up;;
		g | G ) quit=y;;
		*) echo "Sorry, choice not recongnized";;
	esac
done
}



Rx_Mode() {
echo **********************RX Mode Setting of Wi-Fi Certification Test********************
ifconfig ra0 down
ifconfig ra0 up

#iwpriv ra0 set ATE=ATESTOP
iwpriv ra0 set ATE=ATESTART
iwpriv ra0 set ATECHANNEL=6
iwpriv ra0 set ATETXFREQOFFSET=38
iwpriv ra0 set ATETXMODE=1
iwpriv ra0 set ATETXMCS=7
iwpriv ra0 set ATETXBW=0
iwpriv ra0 set ATERXFER=0
iwpriv ra0 set ATERXANT=0
iwpriv ra0 set ATE=RXFRAME
iwpriv ra0 set ResetCounter=0

echo
iwpriv ra0 set ATESHOW=1
iwpriv ra0 stat
echo "set finished"
sleep 1
}

main() {
true=1
while [ "$true" = "1" ];
do
	clear
	echo "******************************* Wi-Fi Certification Test*****************************"
	echo "Options :"
	echo "       1) TX Mode"
	echo "       2) RX Mode"
	echo "       0) Quit"
	echo
	echo -n "menu_choice: "
	read menu_choice
	case "$menu_choice" in
		1) Tx_Mode;;
		2) Rx_Mode;;
		0) exit 0;;
		*) echo "Sorry, choice not recongnized";;
	esac
done
}

main

#iwpriv ra0 set ATEHELP=1   // for ATE Command help.
