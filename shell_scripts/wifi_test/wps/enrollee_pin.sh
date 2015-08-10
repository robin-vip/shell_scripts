#!/bin/sh


echo " Enrollee Mode ¡ª¡ª Pin "
#get pin code
iwpriv ra0 stat
read STOP

iwpriv ra0 wsc_conf_mode 1
iwpriv ra0 wsc_mode 1
iwpriv ra0 wsc_ap_band 0
iwpriv ra0 wsc_ssid eagletest
iwpriv ra0 wsc_start

udhcpc -i ra0

iwpriv ra0 connStatus	
