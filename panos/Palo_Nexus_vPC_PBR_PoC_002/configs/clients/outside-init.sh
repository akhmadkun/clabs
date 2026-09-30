#!/usr/bin/env bash
set -eu
sleep 2
ip link set eth1 up
ip addr replace 10.200.200.10/24 dev eth1
ip route replace 10.100.100.0/24 via 10.200.200.1 dev eth1
if command -v iperf3 >/dev/null 2>&1; then
  iperf3 -s -p 5201 -D >/tmp/iperf3.log 2>&1 || true
fi
echo "MT-OUTSIDE ready"
ip -br addr show eth1
