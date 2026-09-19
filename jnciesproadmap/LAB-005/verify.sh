#!/usr/bin/env bash
set -uo pipefail

MODE="${1:-baseline}"
CLIENT="client1"
PASS=0
FAIL=0

test_ping() {
  local ip="$1" expected="$2" label="$3"
  if docker exec "$CLIENT" ping -c 2 -W 1 "$ip" >/dev/null 2>&1; then
    rc=0
  else
    rc=1
  fi
  if [[ "$expected" == "up" && $rc -eq 0 ]]; then
    printf 'PASS %-38s reachable\n' "$label"
    PASS=$((PASS+1))
  elif [[ "$expected" == "down" && $rc -ne 0 ]]; then
    printf 'PASS %-38s blocked\n' "$label"
    PASS=$((PASS+1))
  else
    printf 'FAIL %-38s expected=%s\n' "$label" "$expected"
    FAIL=$((FAIL+1))
  fi
}

case "$MODE" in
  baseline)
    test_ping 10.10.10.10 up   '10.10.10.0/24 GOLD'
    test_ping 10.10.20.20 up   '10.10.20.0/24 SILVER'
    test_ping 10.10.20.200 up  '10.10.20.128/25 SILVER more-specific'
    test_ping 10.10.30.130 up  '10.10.30.128/25 Customer-A'
    test_ping 10.10.40.40 up   '10.10.40.0/24 Customer-A'
    test_ping 10.20.10.10 up   '10.20.10.0/24 outside Customer-A'
    ;;
  final)
    test_ping 10.10.10.10 up   '10.10.10.0/24 GOLD approved'
    test_ping 10.10.20.20 down '10.10.20.0/24 SILVER rejected'
    test_ping 10.10.20.200 down '10.10.20.128/25 SILVER rejected'
    test_ping 10.10.30.130 up  '10.10.30.128/25 Customer-A approved'
    test_ping 10.10.40.40 up   '10.10.40.0/24 Customer-A approved'
    test_ping 10.20.10.10 down '10.20.10.0/24 import rejected'
    ;;
  *)
    echo "Usage: $0 {baseline|final}"
    exit 2
    ;;
esac

echo
if [[ $FAIL -eq 0 ]]; then
  echo "RESULT: PASS"
  exit 0
else
  echo "RESULT: FAIL ($FAIL failed, $PASS passed)"
  exit 1
fi
