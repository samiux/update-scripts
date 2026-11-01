#!/bin/bash

server1='127.0.0.1'
usb1='152d:0578'
#usb2='0658:0200'

/usr/bin/usbip attach -r $server1 -b $(/usr/bin/usbip list -r $server1 | grep $usb1 | cut -d: -f1)
#/usr/sbin/usbip attach -r $server1 -b $(/usr/sbin/usbip list -r $server1 | grep $usb2 | cut -d: -f1)
