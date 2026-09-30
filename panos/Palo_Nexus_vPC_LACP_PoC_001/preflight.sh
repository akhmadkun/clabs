#!/usr/bin/env bash
set -u

IMAGES=(
  "arthurk99/cisco-nxos9000v:10.3.5"
  "vrnetlab/paloalto_pa-vm:11.2.5"
  "ghcr.io/srl-labs/network-multitool:latest"
)

echo "==============================================================="
echo "POC-001 Pre-flight"
echo "==============================================================="

echo
echo "[1] Containerlab"
if command -v containerlab >/dev/null 2>&1; then
  containerlab version
else
  echo "ERROR: containerlab not found"
fi

echo
echo "[2] Docker images"
for img in "${IMAGES[@]}"; do
  if docker image inspect "${img}" >/dev/null 2>&1; then
    echo "OK   ${img}"
  else
    echo "MISS ${img}"
  fi
done

echo
echo "[3] KVM"
if [[ -e /dev/kvm ]]; then
  echo "OK   /dev/kvm exists"
else
  echo "WARN /dev/kvm missing; VM-based nodes may not start"
fi

echo
echo "[4] Linux bonding module"
if modinfo bonding >/dev/null 2>&1; then
  echo "OK   bonding module available"
else
  echo "WARN bonding module is not available; client LACP tests may fail"
fi
