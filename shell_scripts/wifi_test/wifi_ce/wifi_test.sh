#!/bin/sh
echo " set ra0 "

fun_power() {
iwpriv ra0 set ATE=ATESTOP

iwpriv ra0 set ATE=ATESTART

iwpriv ra0 set ATEDA=00:11:22:33:44:55

iwpriv ra0 set ATESA=00:aa:bb:cc:dd:ee

iwpriv ra0 set ATEBSSID=00:11:22:33:44:55

iwpriv ra0 set ATECHANNEL=8

iwpriv ra0 set ATETXMODE=1

iwpriv ra0 set ATETXMCS=7

iwpriv ra0 set ATETXBW=0

iwpriv ra0 set ATETXGI=0

iwpriv ra0 set ATETXLEN=1024

iwpriv ra0 set ATETXCNT=100000000

iwpriv ra0 set ATETXFREQOFFSET=32

iwpriv ra0 set ATETXANT=0

iwpriv ra0 set ATE=TXCONT

iwpriv ra0 set ATETXPOW0=20
}

fun_fre() {
iwpriv ra0 set ATE=ATESTOP

iwpriv ra0 set ATE=ATESTART

iwpriv ra0 set ATEDA=00:11:22:33:44:55

iwpriv ra0 set ATESA=00:aa:bb:cc:dd:ee

iwpriv ra0 set ATEBSSID=00:11:22:33:44:55

iwpriv ra0 set ATECHANNEL=8

iwpriv ra0 set ATETXMODE=1

iwpriv ra0 set ATETXMCS=7

iwpriv ra0 set ATETXBW=0

iwpriv ra0 set ATETXGI=0

iwpriv ra0 set ATETXLEN=1024

iwpriv ra0 set ATETXCNT=100000000

iwpriv ra0 set ATETXFREQOFFSET=32

iwpriv ra0 set ATETXANT=0

iwpriv ra0 set ATE=TXCARR

iwpriv ra0 set ATETXPOW0=20
}

i=0
while [ "$i" != "5" ];
do
	ifconfig ra0 down
	ifconfig ra0 up
	i=$(($i+1))
	fun_fre 
	sleep 1
done