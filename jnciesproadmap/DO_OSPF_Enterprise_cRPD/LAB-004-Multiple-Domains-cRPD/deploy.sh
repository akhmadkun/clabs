#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if ! ip link show br-univ >/dev/null 2>&1; then
  echo "ERROR: host bridge br-univ does not exist or is not visible."
  echo "This lab references the universal bridge; it does not create or delete it."
  exit 1
fi
if ! ip -br link show br-univ | awk '{print $2}' | grep -q 'UP'; then
  echo "ERROR: host bridge br-univ exists but is not UP. Bring it UP before deployment."
  exit 1
fi

# These labs share the same external bridge plus overlapping VLAN/IP plans.
# Only one such OSPF lab should run at once.
for lab in ospf001 ospf002 ospf003; do
  for node in r1 r2 r3 r4; do
    if docker inspect "clab-${lab}-${node}" >/dev/null 2>&1; then
      echo "ERROR: found clab-${lab}-${node}. Destroy that previous OSPF lab first."
      exit 1
    fi
  done
done

for node in r1 r2 r3 r4 r6 r7 ep16 ep17 ep18; do
  if docker inspect "clab-ospf004-${node}" >/dev/null 2>&1; then
    echo "ERROR: found existing LAB-004 node clab-ospf004-${node}. Run ./destroy.sh first."
    exit 1
  fi
done

containerlab deploy -t lab-004.clab.yml
printf '
Next step: ./configure-hosts.sh
'
