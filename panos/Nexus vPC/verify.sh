#!/usr/bin/env bash
set -euo pipefail

TOPO="lab-001.clab.yml"

echo "== Containerlab status =="
clab inspect -t "$TOPO" || true

echo
echo "== Expected verification commands =="

cat <<'EOF'
NX1:
  show version
  show interface brief
  show port-channel summary
  show lacp neighbor
  show interface port-channel 10
  show ip interface brief
  show ip route 10.255.0.2/32

IOL1:
  show ip interface brief
  show etherchannel summary
  show lacp neighbor
  show interfaces port-channel 10
  show ip route 10.255.0.1
  show ip cef 10.255.0.1

Traffic:
  NX1:  ping 10.10.10.2
  NX1:  ping 10.255.0.2 source 10.255.0.1
  IOL1: ping 10.10.10.1
  IOL1: ping 10.255.0.1 source 10.255.0.2
EOF
