#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if ! ip link show br-univ >/dev/null 2>&1; then
  echo "ERROR: host bridge br-univ does not exist or is not visible."
  echo "This lab references the external bridge; it never creates/deletes it."
  exit 1
fi
if ! ip -br link show br-univ | awk '{print $2}' | grep -q 'UP'; then
  echo "ERROR: host bridge br-univ exists but is not UP. Bring it UP first."
  exit 1
fi

# Labs share a physical bridge and overlapping address/VLAN plans; only one at once.
for lab in ospf001 ospf002 ospf003 ospf004; do
  for node in r1 r2 r3 r4 r6 r7 r8 r9 ep16 ep17 ep18 ep91 ep92; do
    if docker inspect "clab-${lab}-${node}" >/dev/null 2>&1; then
      echo "ERROR: found clab-${lab}-${node}. Destroy the previous OSPF lab first."
      exit 1
    fi
  done
done

for node in r1 r2 r3 r4 r6 r7 r8 r9 ep16 ep17 ep18 ep91 ep92; do
  if docker inspect "clab-ospf005-${node}" >/dev/null 2>&1; then
    echo "ERROR: found existing LAB-005 node clab-ospf005-${node}. Run ./destroy.sh first."
    exit 1
  fi
done

containerlab deploy -t lab-005.clab.yml
printf '\nNext: ./configure-hosts.sh\n'
