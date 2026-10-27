#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if ! ip link show br-univ >/dev/null 2>&1; then
  echo "ERROR: host bridge br-univ does not exist or is not visible."
  echo "This lab reuses the existing universal bridge; it does not create or delete it."
  exit 1
fi
if ! ip -br link show br-univ | awk '{print $2}' | grep -q 'UP'; then
  echo "ERROR: host bridge br-univ exists but is not UP. Bring it UP before deployment."
  exit 1
fi

# LAB-001 and LAB-002 reuse router IDs, VLAN IDs and IP prefixes. Never run them together.
for node in r1 r2 r3 r4; do
  if docker inspect "clab-ospf001-${node}" >/dev/null 2>&1; then
    echo "ERROR: found clab-ospf001-${node}."
    echo "Destroy LAB-001 first, then deploy LAB-002; the duplicated VLANs/IPs/router IDs would conflict."
    exit 1
  fi
done

containerlab deploy -t lab-002.clab.yml
printf '\nNext step: ./configure-hosts.sh\n'
