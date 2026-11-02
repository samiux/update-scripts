#!/usr/bin/env bash
# 只在显式 stop/restart 时执行：策略性释放设备
set -uo pipefail
CONF=/etc/usbip/usbip-server.conf
[ -r "$CONF" ] && . "$CONF"
UNBIND_ON_STOP=${UNBIND_ON_STOP:-1}

log(){ logger -t usbip-server -p daemon.info -- "$*" 2>/dev/null || true; }

[ "$UNBIND_ON_STOP" = 1 ] || exit 0

for busid in $(usbip list -l 2>/dev/null \
      | sed -n 's/.*busid[[:space:]]\+\([^[:space:]]*\).*/\1/p'); do
    if usbip unbind -b "$busid" >/dev/null 2>&1; then
        log "unbound $busid on stop"
    fi
done
exit 0
