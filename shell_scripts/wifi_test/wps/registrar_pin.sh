#!/bin/sh


echo " Registrar Mode ¡ª¡ª Pin "
iwpriv ra0 wsc_conf_mode 2
iwpriv ra0 wsc_mode 1
echo "PinCode="
read PinCode
iwpriv ra0 wsc_pin $PinCode
iwpriv ra0 wsc_ap_band 0
iwpriv ra0 wsc_ssid eagletest
iwpriv ra0 wsc_start

udhcpc -i ra0

iwpriv ra0 connStatus	
