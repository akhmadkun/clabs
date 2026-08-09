#!/usr/bin/env bash
set -u

client="client1"
failed=0

check_ping() {
  local destination="$1"
  local label="$2"
  if docker exec "$client" ping -c 3 -W 2 "$destination" >/dev/null 2>&1; then
    printf 'PASS  %s (%s)\n' "$label" "$destination"
  else
    printf 'FAIL  %s (%s)\n' "$label" "$destination"
    failed=1
  fi
}

printf 'LAB-001 basic data-plane verification\n'
check_ping 192.168.10.1 'Client to R1'
check_ping 10.0.12.2 'Client through R1 to R2'
check_ping 10.255.0.1 'Client to R1 loopback'
check_ping 10.255.0.2 'Client to R2 loopback'

if [ "$failed" -eq 0 ]; then
  printf 'RESULT: PASS\n'
else
  printf 'RESULT: FAIL\n'
fi

exit "$failed"
