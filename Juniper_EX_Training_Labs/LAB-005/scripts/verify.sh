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

if ! docker inspect sw1 >/dev/null 2>&1; then
    echo "ERROR: container 'sw1' not found. Deploy LAB-005 first."
    exit 1
fi

if ! docker inspect host1 >/dev/null 2>&1 || ! docker inspect host2 >/dev/null 2>&1; then
    echo "ERROR: host1 or host2 container not found. Deploy LAB-005 first."
    exit 1
fi

echo "============================================================"
echo "LAB-005 END-TO-END VERIFICATION"
echo "============================================================"

echo
check "Host1 -> Host2" docker exec host1 ping -c 4 -W 1 10.10.10.12
check "Host2 -> Host1" docker exec host2 ping -c 4 -W 1 10.10.10.11

echo
cat <<'MSG'
============================================================
MANUAL JUNOS OPERATIONS CHECKLIST
============================================================
Run these on EX-TRAIN-SW1:

  show version
  show system uptime
  show system alarms
  show system commit
  show interfaces terse | match "ge-0/0/(10|11)[.]0"
  show configuration interfaces ge-0/0/10
  show configuration interfaces ge-0/0/11
  show vlans USERS
  show ethernet-switching table vlan-name USERS
  show log messages | last 20

Confirm that:
- ge-0/0/10 and ge-0/0/11 are enabled and operational
- both access ports are in VLAN USERS (VLAN 10)
- the final descriptions are HOST1-ACCESS and HOST2-ACCESS
- the hosts' MAC addresses appear after traffic is generated

The script intentionally checks host reachability automatically. Switch
state is reviewed manually so that trainees practice reading Junos output.
MSG

echo
echo "RESULT: $PASS passed, $FAIL failed"
if [ "$FAIL" -eq 0 ]; then
    exit 0
else
    exit 1
fi
