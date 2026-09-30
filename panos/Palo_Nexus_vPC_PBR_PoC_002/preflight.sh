#!/usr/bin/env bash
set -u

IMAGES=(
  "arthurk99/cisco-nxos9000v:10.3.5"
  "vrnetlab/paloalto_pa-vm:11.2.5"
  "ghcr.io/srl-labs/network-multitool:latest"
)

echo "=============================================================="
echo "POC-002 preflight"
echo "=============================================================="

echo
if command -v containerlab >/dev/null 2>&1; then
  echo "[Containerlab]"
  containerlab version
else
  echo "ERROR: containerlab not found"
fi

echo
echo "[Docker images]"
for image in "${IMAGES[@]}"; do
  if docker image inspect "${image}" >/dev/null 2>&1; then
    echo "OK   ${image}"
  else
    echo "MISS ${image}"
  fi
done

echo
echo "[KVM]"
if [[ -e /dev/kvm ]]; then
  echo "OK   /dev/kvm exists"
else
  echo "WARN /dev/kvm not found; VM nodes may fail"
fi

echo
echo "Preflight complete."
