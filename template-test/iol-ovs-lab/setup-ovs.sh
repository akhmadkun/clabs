#!/usr/bin/env bash
set -euo pipefail

BRIDGE="ovs"

if ! command -v ovs-vsctl >/dev/null 2>&1; then
  echo "ERROR: ovs-vsctl not found. Install Open vSwitch first."
  exit 1
fi

if ovs-vsctl br-exists "$BRIDGE"; then
  echo "OVS bridge '$BRIDGE' already exists."
else
  sudo ovs-vsctl add-br "$BRIDGE"
  echo "Created OVS bridge '$BRIDGE'."
fi

# OVS defaults to VLAN trunk behavior when no access tag is set.
# An empty 'trunks' list means all VLANs are valid.
for p in ovsp1 ovsp2 ovsp3; do
  sudo ovs-vsctl --if-exists set Port "$p" vlan_mode=trunk
  sudo ovs-vsctl --if-exists clear Port "$p" trunks
  sudo ovs-vsctl --if-exists clear Port "$p" tag
 done

echo
sudo ovs-vsctl show
