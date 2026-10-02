#!/usr/bin/env bash
set -u

PASS=0
FAIL=0

check() {
  local name="$1"
  shift
  if "$@" >/tmp/lab002_verify.out 2>&1; then
    echo "[PASS] $name"
    PASS=$((PASS+1))
  else
    echo "[FAIL] $name"
    cat /tmp/lab002_verify.out
    FAIL=$((FAIL+1))
  fi
}

container_exists() {
  docker inspect "$1" >/dev/null 2>&1
}

show_junos() {
  local node="$1"
  local cmd="$2"
  docker exec "$node" cli -c "$cmd" >/tmp/lab002_verify.out 2>&1
}

if ! container_exists sw1 || ! container_exists sw2 || ! container_exists host1 || ! container_exists host2; then
  echo "[FAIL] Required containers are not all present."
  echo "Run: containerlab deploy -t clab.yml"
  exit 1
fi

check "SW1 ae0 exists" show_junos sw1 "show interfaces ae0 terse"
check "SW2 ae0 exists" show_junos sw2 "show interfaces ae0 terse"
check "SW1 LACP state" show_junos sw1 "show lacp interfaces ae0"
check "SW2 LACP state" show_junos sw2 "show lacp interfaces ae0"
check "SW1 ae0 carries USERS" show_junos sw1 "show configuration interfaces ae0 | match USERS"
check "SW2 ae0 carries USERS" show_junos sw2 "show configuration interfaces ae0 | match USERS"
check "HOST1 can ping HOST2" docker exec host1 ping -c 3 -W 2 10.10.10.12

cat <<EOF2

============================================================
LAB-002 VERIFY SUMMARY
============================================================
PASS: $PASS
FAIL: $FAIL
============================================================
EOF2

if [ "$FAIL" -ne 0 ]; then
  exit 1
fi
