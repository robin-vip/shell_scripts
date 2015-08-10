#!/bin/sh


echo " Enrollee Mode ¡ª¡ª PBC "
iwpriv ra0 wsc_conf_mode 1
iwpriv ra0 wsc_mode 2
iwpriv ra0 wsc_ap_band 0
iwpriv ra0 wsc_start

udhcpc -i ra0

iwpriv ra0 connStatus	
