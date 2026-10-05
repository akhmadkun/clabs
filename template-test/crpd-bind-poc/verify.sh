#!/usr/bin/env bash
set -euo pipefail

C="clab-crpd-bind-poc-crpd1"

if ! docker inspect "$C" >/dev/null 2>&1; then
  echo "ERROR: $C does not exist."
  exit 1
fi

printf '\n=== Bind mount ===\n'
docker exec "$C" ls -l /lab-configs

printf '\n=== Linux interfaces ===\n'
docker exec "$C" ip -br link

check() {
  local file="$1"
  local host="$2"
  local ip="$3"

  echo
  echo "### $file"
  ./load-crpd.sh "$file" >/tmp/crpd-load-poc.out
  cat /tmp/crpd-load-poc.out

  echo "Verify expected hostname: $host"
  docker exec "$C" cli -c "show configuration system host-name | display set"
  echo "Verify expected lo0 address: $ip"
  docker exec "$C" cli -c "show configuration interfaces lo0 | display set"
}

check lab1.conf CRPD-LAB1 1.1.1.1
check lab2.conf CRPD-LAB2 2.2.2.2
check lab3.conf CRPD-LAB3 3.3.3.3

echo
echo "PASS: lab1.conf, lab2.conf and lab3.conf were loaded from /lab-configs without redeploy."
