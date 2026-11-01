#!/bin/bash

# ADATA 512GB SSD
usb1='152d:0578'
#usb2='0658:0200'

/usr/bin/usbip bind --$(/usr/bin/usbip list -p -l | grep '#usbid='$usb1'#' | cut '-d#' -f1)
#/usr/bin/usbip bind --$(/usr/bin/usbip list -p -l | grep '#usbid='$usb2'#' | cut '-d#' -f1)
