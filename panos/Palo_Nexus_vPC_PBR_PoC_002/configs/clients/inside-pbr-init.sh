#!/usr/bin/env bash
set -eu
sleep 2
ip link set eth1 up
ip addr replace 10.100.100.10/24 dev eth1
ip route replace 10.200.200.0/24 via 10.100.100.1 dev eth1
echo "MT-INSIDE-PBR ready"
ip -br addr show eth1
