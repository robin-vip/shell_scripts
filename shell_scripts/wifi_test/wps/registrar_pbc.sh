#!/bin/sh


echo " Enrollee Mode ���� Pin "
#get pin code
iwpriv ra0 stat
read STOP

iwpriv ra0 wsc_conf_mode 2
iwpriv ra0 wsc_mode 2
iwpriv ra0 wsc_ap_band 0
iwpriv ra0 wsc_start

udhcpc -i ra0

iwpriv ra0 connStatus	
