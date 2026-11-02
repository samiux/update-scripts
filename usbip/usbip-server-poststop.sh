#!/usr/bin/env bash
# ExecStopPost：正常停、崩溃重启都会跑，只做幂等清理
set -uo pipefail
pkill -x usbipd 2>/dev/null || true
for _ in $(seq 1 20); do
    pgrep -x usbipd >/dev/null 2>&1 || break
    sleep 0.1
done
pkill -9 -x usbipd 2>/dev/null || true
exit 0   # 永远成功，否则会污染 Restart 判定
