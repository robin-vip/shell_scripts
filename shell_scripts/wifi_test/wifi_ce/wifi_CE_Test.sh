#!/bin/sh
echo " set ra0 "

function_cmd() {
#ifconfig ra0 down
#ifconfig ra0 up

clear

iwpriv ra0 set ATE=ATESTOP
echo ********************************set output power******************************
iwpriv ra0 set ATETXPOW0=$5
echo *************************************end*********************************
echo
iwpriv ra0 set ATE=ATESTART

iwpriv ra0 set ATEDA=00:11:22:33:44:55
iwpriv ra0 set ATESA=00:aa:bb:cc:dd:ee
iwpriv ra0 set ATEBSSID=00:11:22:33:44:55

echo ********************************set Channel******************************
iwpriv ra0 set ATECHANNEL=$4
echo *************************************end*********************************
echo

echo ***********************************set ATE Tx MODE***********************
iwpriv ra0 set ATETXMODE=$1
echo *****************************************emd*****************************

iwpriv ra0 set ATETXMCS=7

echo **********************************set BandWidth**************************
iwpriv ra0 set ATETXBW=$2
echo ***************************************end*******************************
echo

iwpriv ra0 set ATETXGI=0
iwpriv ra0 set ATETXLEN=1024
iwpriv ra0 set ATETXCNT=100000000
iwpriv ra0 set ATETXFREQOFFSET=32
iwpriv ra0 set ATETXANT=0
iwpriv ra0 set ATE=TXFRAME
#iwpriv ra0 set ATE=TXCONT


echo ********************************set Data rate****************************
iwpriv ra0 set TxRate=$3
echo *************************************end*********************************
echo

}


i=0
while [ "$i" != "5" ];
do
	i=$(($i+1))
	function_cmd "$1" "$2" "$3" "$4" "$5"
	sleep 1
done