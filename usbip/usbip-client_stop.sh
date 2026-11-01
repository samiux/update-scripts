#!/bin/bash

/usr/bin/usbip detach --port=$(/usr/bin/usbip port | grep '<Port in Use>' | sed -E 's/^Port ([0-9][0-9]).*/\1/')
#/usr/bin/usbip detach --port=$(/usr/bin/usbip port | grep '<Port in Use>' | sed -E 's/^Port ([0-9][0-9]).*/\1/')
