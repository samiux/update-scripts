#!/usr/bin/env bash
# USB/IP client: auto-attach + health check + auto-reconnect (HA).
set -uo pipefail

CONF="${USBIP_CLIENT_CONF:-/etc/usbip/usbip-client.conf}"
# shellcheck disable=SC1090
[ -r "$CONF" ] && . "$CONF"

SERVERS=${SERVERS:-}
INTERVAL=${INTERVAL:-5}
TCP_PORT=${TCP_PORT:-3240}
DEVICES=${DEVICES:-}                 # busid 白名单，空=全部
DETACH_ON_REMOVE=${DETACH_ON_REMOVE:-1}
LIST_TIMEOUT=${LIST_TIMEOUT:-5}

log()    { logger -t usbip-client -p daemon.info -- "$*" 2>/dev/null || true; }
notify() { command -v systemd-notify >/dev/null && systemd-notify "$@" 2>/dev/null || true; }
in_list(){ local x=$1; shift; local i; for i in "$@"; do [ "$i" = "$x" ] && return 0; done; return 1; }

[ -n "$SERVERS" ] || { log "FATAL: SERVERS empty"; exit 1; }
modprobe vhci_hcd 2>/dev/null || { log "FATAL: vhci-hcd load failed"; exit 1; }

declare -A reported_fail=()

# ---- 解析 vhci 状态 ----------------------------------------------------------
vhci_status_file() {
    local f
    for f in /sys/devices/platform/vhci_hcd.*/status; do
        [ -r "$f" ] && { printf '%s\n' "$f"; return 0; }
    done
    return 1
}

# 输出 "port<TAB>server:port<TAB>busid"
list_attached() {
    usbip port 2>/dev/null | awk '
        /^Port[[:space:]]+[0-9]+:/ {
            p=$2; sub(":","",p); port=p; next
        }
        {
            for (i=1;i<=NF;i++) {
                if (index($i,"usbip://")) {
                    u=$i; sub(".*usbip://","",u)
                    s=u; sub("/.*","",s)
                    b=u; sub(".*/","",b)
                    printf "%s\t%s\t%s\n", port, s, b
                    next
                }
            }
        }'
}

# 输出 "已 attach 但 socket 已断" 的端口号（十进制）
dead_ports() {
    local f; f=$(vhci_status_file) || return 0
    local hub port sta spd dev sock lb
    while read -r hub port sta spd dev sock lb; do
        [ "$hub" = "hub" ] && continue
        [ -n "${port:-}" ] || continue
        [ $((16#${sta:-0})) -eq 4 ] || continue       # 4 = attached
        case "$sock" in *[!0]*) continue;; esac       # 有非 0 位 => 连接仍在
        printf '%d\n' $((16#$port))
    done < "$f"
}

remote_busids() {
    local host=$1 out
    out=$(timeout "$LIST_TIMEOUT" usbip list -r "$host" 2>/dev/null) || return 1
    [ -n "$out" ] || return 1
    printf '%s\n' "$out" \
      | sed -n 's/^[[:space:]]\+\([0-9][0-9.+-]*\):.*/\1/p'
}

# ---- 单轮同步 ---------------------------------------------------------------
scan_once() {
    local port host skey busid key s b
    local attached busids

    # 1) 清理"半死"端口：连接已断但 vhci 端口仍占用 -> detach 后重新 attach
    while read -r port; do
        [ -n "$port" ] || continue
        log "detach dead vhci port $port"
        usbip detach -p "$port" >/dev/null 2>&1 || true
    done < <(dead_ports)

    # 2) 记录当前已导入设备
    declare -A have=()
    attached=$(list_attached)
    if [ -n "$attached" ]; then
        while IFS=$'\t' read -r port s b; do
            [ -n "${port:-}" ] || continue
            have["$s/$b"]=$port
        done <<< "$attached"
    fi

    # 3) 逐服务器同步
    for host in $SERVERS; do
        skey="$host:$TCP_PORT"
        if ! busids=$(remote_busids "$host"); then
            if [ -z "${reported_fail[list:$host]:-}" ]; then
                log "server $host unreachable, will keep retrying"
                reported_fail["list:$host"]=1
            fi
            continue
        fi
        unset "reported_fail[list:$host]" 2>/dev/null || true

        for busid in $busids; do
            if [ -n "$DEVICES" ] && ! in_list "$busid" $DEVICES; then
                continue
            fi
            if [ -n "${have[$skey/$busid]:-}" ]; then
                continue
            fi
            if usbip attach -r "$host" -b "$busid" >/dev/null 2>&1; then
                log "attached $host/$busid"
                unset "reported_fail[attach:$host/$busid]" 2>/dev/null || true
            else
                if [ -z "${reported_fail[attach:$host/$busid]:-}" ]; then
                    log "attach failed $host/$busid (retrying quietly)"
                    reported_fail["attach:$host/$busid"]=1
                fi
            fi
        done

        if [ "$DETACH_ON_REMOVE" = 1 ]; then
            for key in "${!have[@]}"; do
                s=${key%/*}; b=${key#*/}
                [ "$s" = "$skey" ] || continue
                if ! in_list "$b" $busids; then
                    log "remote device gone $skey/$b, detaching port ${have[$key]}"
                    usbip detach -p "${have[$key]}" >/dev/null 2>&1 || true
                fi
            done
        fi
    done
}

trap ':' USR1
trap 'log "usbip-client stopping"; exit 0' TERM INT

notify --ready --status="usbip client running"
log "usbip-client started for: $SERVERS"

while :; do
    scan_once
    notify WATCHDOG=1
    sleep "$INTERVAL" &
    wait $! 2>/dev/null || true
done
