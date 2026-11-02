#!/usr/bin/env bash
# USB/IP server: auto-export + hotplug + self-healing, systemd notify/Watchdog.
set -uo pipefail

CONF="${USBIP_SERVER_CONF:-/etc/usbip/usbip-server.conf}"
# shellcheck disable=SC1090
[ -r "$CONF" ] && . "$CONF"

INTERVAL=${INTERVAL:-3}          # 扫描周期（秒）
USBIPD_OPTS=${USBIPD_OPTS:-}     # 传给 usbipd 的额外参数
EXPORT_ONLY=${EXPORT_ONLY:-}     # 空格分隔的 busid 白名单；空=全部导出
DRIVER_DIR=/sys/bus/usb/drivers/usbip-host

log()    { logger -t usbip-server -p daemon.info -- "$*" 2>/dev/null || true; }
notify() { command -v systemd-notify >/dev/null && systemd-notify "$@" 2>/dev/null || true; }
in_list(){ local x=$1; shift; local i; for i in "$@"; do [ "$i" = "$x" ] && return 0; done; return 1; }

declare -A reported_fail=()

start_usbipd() {
    pgrep -x usbipd >/dev/null 2>&1 && return 0
    # shellcheck disable=SC2086
    if usbipd -D $USBIPD_OPTS; then
        log "usbipd started"
    else
        log "usbipd start FAILED"
        return 1
    fi
}

is_exported() {
    local busid=$1
    [ -d "$DRIVER_DIR" ] || return 1
    ls "$DRIVER_DIR" 2>/dev/null | grep -q "^${busid}:"
}

local_busids() {
    usbip list -l 2>/dev/null \
      | sed -n 's/.*busid[[:space:]]\+\([^[:space:]]*\).*/\1/p'
}

scan_once() {
    local busid
    for busid in $(local_busids); do
        if [ -n "$EXPORT_ONLY" ] && ! in_list "$busid" $EXPORT_ONLY; then
            continue
        fi
        if is_exported "$busid"; then
            unset "reported_fail[$busid]" 2>/dev/null || true
            continue
        fi
        if usbip bind -b "$busid" >/dev/null 2>&1; then
            log "exported $busid"
            unset "reported_fail[$busid]" 2>/dev/null || true
        else
            if [ -z "${reported_fail[$busid]:-}" ]; then
                log "bind failed for $busid (will retry quietly)"
                reported_fail[$busid]=1
            fi
        fi
    done
}

# SIGUSR1 触发立即扫描（udev 用），TERM/INT 干净退出
trap ':' USR1
trap 'log "usbip-server stopping"; exit 0' TERM INT

modprobe usbip_core 2>/dev/null || true
modprobe usbip_host 2>/dev/null || { log "FATAL: usbip-host missing"; exit 1; }

notify --ready --status="usbip server running"
log "usbip-server started (interval=${INTERVAL}s)"

while :; do
    start_usbipd || true
    scan_once
    notify WATCHDOG=1
    sleep "$INTERVAL" &
    wait $! 2>/dev/null || true
done
