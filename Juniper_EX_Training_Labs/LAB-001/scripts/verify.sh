#!/usr/bin/env bash
set -euo pipefail

command -v docker >/dev/null 2>&1 || { echo "ERROR: docker not found"; exit 1; }

for c in sw1 sw2 host1 host2; do
  docker inspect "$c" >/dev/null 2>&1 || { echo "ERROR: container $c not found"; exit 1; }
done

echo "== Container status =="
docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -E 'sw1|sw2|host1|host2' || true

echo "== HOST1 -> HOST2 ping =="
docker exec host1 ping -c 3 10.10.10.12

echo "== Verification complete =="
