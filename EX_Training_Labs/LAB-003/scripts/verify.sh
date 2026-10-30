#!/usr/bin/env bash
set -u

echo "============================================================"
echo "LAB-003 RSTP BASIC VERIFICATION"
echo "============================================================"

echo
echo "[1] Container status"
docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E '^(sw1|sw2|sw3|host1|host2)[[:space:]]' || true

echo
echo "[2] Host1 -> Host2"
docker exec host1 ping -c 3 -W 2 10.10.10.12 || true

echo
echo "[3] Host2 -> Host1"
docker exec host2 ping -c 3 -W 2 10.10.10.11 || true

for sw in sw1 sw2 sw3; do
  echo
  echo "[RSTP] $sw"
  docker exec "$sw" cli -c 'show spanning-tree' || true
done

echo
echo "[VLAN] SW1 USERS"
docker exec sw1 cli -c 'show vlans USERS' || true

echo
echo "============================================================"
echo "Use SOLUTION-GUIDE.txt for detailed task-by-task verification."
echo "============================================================"
