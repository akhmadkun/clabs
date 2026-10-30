#!/usr/bin/env bash
set -u

PASS=0
FAIL=0

check() {
    local name="$1"
    shift
    echo "[CHECK] $name"
    if "$@"; then
        echo "  PASS"
        PASS=$((PASS+1))
    else
        echo "  FAIL"
        FAIL=$((FAIL+1))
    fi
}

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: docker command not found."
    exit 1
fi

echo "============================================================"
echo "LAB-004 END-TO-END VERIFICATION"
echo "============================================================"

echo
check "Host1 -> Host2" docker exec host1 ping -c 4 -W 1 10.10.10.12
check "Host2 -> Host1" docker exec host2 ping -c 4 -W 1 10.10.10.11

cat <<'MSG'

============================================================
MANUAL SWITCH CHECKS
============================================================
Run these on the Junos switches after the ping test:

SW1/SW3 host ports:
  show interfaces terse | match "ge-0/0/10[.]0"
  show configuration interfaces ge-0/0/10

Inter-switch links:
  show interfaces terse | match "ge-0/0/(1|2)[.]0"
  show configuration interfaces ge-0/0/1
  show configuration interfaces ge-0/0/2

VLAN:
  show vlans USERS

RSTP:
  show spanning-tree bridge
  show spanning-tree interface

MAC learning:
  show ethernet-switching table vlan-name USERS

The helper script intentionally keeps switch-state validation manual so
that the trainee still practices reading Junos operational output.
MSG

echo
echo "RESULT: $PASS passed, $FAIL failed"

if [ "$FAIL" -eq 0 ]; then
    exit 0
else
    exit 1
fi
