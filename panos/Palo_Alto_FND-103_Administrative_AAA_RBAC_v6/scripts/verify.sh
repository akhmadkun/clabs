#!/usr/bin/env bash
set -euo pipefail

fail=0
ok(){ printf '[OK] %s\n' "$*"; }
bad(){ printf '[FAIL] %s\n' "$*"; fail=1; }

for c in radius tacacs aa-test; do
  docker inspect "$c" >/dev/null 2>&1 || { bad "$c container not found"; continue; }
  state=$(docker inspect -f '{{.State.Status}}' "$c")
  [ "$state" = running ] && ok "$c is running" || bad "$c state=$state"
  restart=$(docker inspect -f '{{.RestartCount}}' "$c")
  [ "$restart" = 0 ] && ok "$c restart count is 0" || bad "$c restart count=$restart"
done

check_ip() {
  c="$1"; want="$2"
  got=$(docker exec "$c" sh -c "ip -4 -o addr show dev eth1 2>/dev/null | awk '{print \$4}'" || true)
  [ "$got" = "$want" ] && ok "$c eth1=$want" || bad "$c eth1 expected $want, got '$got'"
}
check_ip radius 192.168.122.20/24
check_ip tacacs 192.168.122.21/24
check_ip aa-test 192.168.122.30/24

for c in radius tacacs; do
  if docker exec "$c" sh -c 'ss -lunpt 2>/dev/null || netstat -lntup 2>/dev/null' | grep -Eq '(:1812|:49)'; then
    ok "$c exposes an AAA listening socket"
  else
    bad "$c has no expected AAA listening socket"
  fi
done

for dst in 192.168.122.10 192.168.122.20 192.168.122.21 192.168.122.30; do
  docker exec aa-test sh -c "ping -c 2 -W 1 $dst >/dev/null" && ok "aa-test can ping $dst" || bad "aa-test cannot ping $dst"
done

printf '%s\n' '--- persistence check ---'
sleep 15
for c in radius tacacs; do
  restart=$(docker inspect -f '{{.RestartCount}}' "$c")
  [ "$restart" = 0 ] && ok "$c still has restart count 0 after 15s" || bad "$c restarted during persistence check"
done
check_ip radius 192.168.122.20/24
check_ip tacacs 192.168.122.21/24

if (( fail )); then
  printf '%s\n' 'VERIFY FAILED'
  exit 1
fi
printf '%s\n' 'VERIFY PASSED'
