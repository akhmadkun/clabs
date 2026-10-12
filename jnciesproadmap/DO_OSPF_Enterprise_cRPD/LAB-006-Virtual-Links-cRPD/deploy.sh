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

# Only one lab in this series should attach to the shared bridge at a time.
prev_nodes="r1 r2 r3 r4 r6 r7 r8 r9 r10 ep16 ep17 ep18 ep76 ep77 ep91 ep92"
for lab in ospf001 ospf002 ospf003 ospf004 ospf005; do
  for node in $prev_nodes; do
    if docker inspect "clab-${lab}-${node}" >/dev/null 2>&1; then
      echo "ERROR: found clab-${lab}-${node}. Destroy the previous OSPF lab first."
      exit 1
    fi
  done
done
for node in r1 r2 r3 r4 r10 ep16 ep17 ep18 ep76 ep77; do
  if docker inspect "clab-ospf006-${node}" >/dev/null 2>&1; then
    echo "ERROR: found existing LAB-006 node clab-ospf006-${node}. Run ./destroy.sh first."
    exit 1
  fi
done

containerlab deploy -t lab-006.clab.yml
printf '\nNext: ./configure-hosts.sh\n'
