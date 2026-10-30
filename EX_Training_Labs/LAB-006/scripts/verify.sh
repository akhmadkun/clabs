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
echo "LAB-006 BASELINE / FINAL CONNECTIVITY VERIFICATION"
echo "============================================================"
echo "Run this before and after fault-injection tests, not during the"
echo "Loop Guard test while STP BPDUs are intentionally suppressed."
echo
check "Host1 -> Host2" docker exec host1 ping -c 4 -W 1 10.10.10.12
check "Host2 -> Host1" docker exec host2 ping -c 4 -W 1 10.10.10.11

cat <<'MSG'

============================================================
MANUAL SWITCH CHECKS
============================================================
Run these commands on the Junos switches:

All switches:
  show spanning-tree bridge
  show spanning-tree interface
  show configuration protocols rstp

SW1 protected/test link to SW4:
  show interfaces terse | match "ge-0/0/3[.]0"
  show interfaces ge-0/0/3
  show log messages | match "BPDU|bpdu|root|Root"

SW3 loop-protected interface toward SW2:
  show interfaces terse | match "ge-0/0/1[.]0"
  show spanning-tree interface
  show log messages | match "loop|Loop|BPDU|bpdu|RSTP|rstp"

SW4 priority:
  show configuration protocols rstp

The verification script checks host connectivity only. The trainee should
manually inspect STP state/logs to verify each protection behavior.
MSG

echo
echo "RESULT: $PASS passed, $FAIL failed"
if [ "$FAIL" -eq 0 ]; then
    exit 0
else
    exit 1
fi
