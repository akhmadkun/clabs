#!/usr/bin/env bash
set -euo pipefail
LAB="csr-bind-config-lab"
for n in csr1 csr2; do
  C="clab-${LAB}-${n}"
  echo "== ${C} =="
  docker inspect "$C" --format '{{range .Mounts}}{{println .Source "->" .Destination .Mode}}{{end}}' | grep '/tftpboot/configs' || {
    echo "ERROR: /tftpboot/configs bind is missing on ${C}" >&2
    exit 1
  }
  docker exec "$C" sh -c 'ls -l /tftpboot/configs/LAB-001/*.cfg /tftpboot/configs/LAB-002/*.cfg'
done

echo
echo "Bind mount verification: OK"
echo "Inside IOS XE, test with:"
echo "  configure replace tftp://10.0.0.2/configs/LAB-001/csr1.cfg force"
