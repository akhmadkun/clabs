#!/usr/bin/env bash
set -u
echo "=== Containerlab ==="
containerlab version 2>/dev/null || true
echo
echo "=== images ==="
for img in ceos:4.35.0F vrnetlab/paloalto_pa-vm:11.2.5 ghcr.io/srl-labs/network-multitool:latest; do
  if docker image inspect "$img" >/dev/null 2>&1; then
    echo "OK   $img"
  else
    echo "MISS $img"
  fi
done
echo
echo "=== KVM ==="
if [[ -e /dev/kvm ]]; then echo "OK /dev/kvm"; else echo "WARN /dev/kvm missing"; fi
