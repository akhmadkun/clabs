#!/usr/bin/env bash
set -euo pipefail

PROJECT="csr-bind-config-lab"

for n in csr1 csr2; do
  C="clab-${PROJECT}-${n}"
  echo "== ${C} =="
  docker inspect "$C" --format '{{range .Mounts}}{{println .Source "->" .Destination .Mode}}{{end}}' \
    | grep '/tftpboot/configs' || {
      echo "ERROR: /tftpboot/configs bind is missing on ${C}" >&2
      exit 1
    }
  docker exec "$C" sh -c 'test -f /tftpboot/configs/LAB-001/'"$n"'.cfg && test -f /tftpboot/configs/LAB-002/'"$n"'.cfg'
  docker exec "$C" sh -c 'echo "--- /tftpboot/configs ---"; find /tftpboot/configs -maxdepth 2 -type f -name "*.cfg" -print'
done

echo
echo "Bind verification: OK"
