#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

if ! ip link show br-univ >/dev/null 2>&1; then
  echo "ERROR: host bridge br-univ does not exist or is not visible."
  echo "This lab reuses the universal bridge; it does not create or delete it."
  exit 1
fi
if ! ip -br link show br-univ | awk '{print $2}' | grep -q 'UP'; then
  echo "ERROR: host bridge br-univ exists but is not UP. Bring it UP before deployment."
  exit 1
fi

# All OSPF labs reuse router IDs, VLAN IDs, and prefixes. Run only one at a time.
for lab in ospf001 ospf002; do
  for node in r1 r2 r3 r4; do
    if docker inspect "clab-${lab}-${node}" >/dev/null 2>&1; then
      echo "ERROR: found clab-${lab}-${node}."
      echo "Destroy the existing OSPF lab first; lab topologies reuse the same IPs/VLANs/router IDs."
      exit 1
    fi
  done
done

for node in r1 r2 r3 r4; do
  if docker inspect "clab-ospf003-${node}" >/dev/null 2>&1; then
    echo "ERROR: found an existing LAB-003 node: clab-ospf003-${node}."
    echo "Run ./destroy.sh before deploying LAB-003 again."
    exit 1
  fi
done

containerlab deploy -t lab-003.clab.yml
printf '\nNext step: ./configure-hosts.sh\n'
