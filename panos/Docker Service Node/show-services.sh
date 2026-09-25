#!/bin/bash
set -euo pipefail
CONTAINER="${1:-clab-palo-fnd101-server}"
docker exec "$CONTAINER" sh -c 'echo "=== PS ==="; ps -ef; echo; echo "=== SOCKETS ==="; ss -H -lntup'
