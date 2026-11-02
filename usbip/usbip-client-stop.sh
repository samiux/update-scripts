#!/usr/bin/env bash
set -uo pipefail
CONF=/etc/usbip/usbip-client.conf
[ -r "$CONF" ] && . "$CONF"
DETACH_ON_STOP=${DETACH_ON_STOP:-1}

[ "$DETACH_ON_STOP" = 1 ] || exit 0

for p in $(usbip port 2>/dev/null \
      | sed -n 's/^Port[[:space:]]\+\([0-9]\+\):.*/\1/p'); do
    usbip detach -p "$p" >/dev/null 2>&1 || true
done

out=$(usbip port 2>&1) || true
if [[ $out == *"open vhci_driver"* ]]; then
    /usr/sbin/modprobe -r vhci-hcd 2>/dev/null
    /usr/sbin/modprobe vhci-hcd
fi

exit 0
