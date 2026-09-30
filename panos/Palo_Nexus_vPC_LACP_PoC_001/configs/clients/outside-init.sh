#!/usr/bin/env bash
set -eu
sleep 3
ip link add bond0 type bond mode 802.3ad
ip link set bond0 type bond lacp_rate fast
ip link set bond0 type bond miimon 100
ip link set eth1 down
ip link set eth2 down
ip link set eth1 master bond0
ip link set eth2 master bond0
ip link set eth1 up
ip link set eth2 up
ip link set bond0 up
ip addr add 10.200.200.10/24 dev bond0
ip route replace default via 10.200.200.1
echo "MT-OUTSIDE READY"
ip -br addr show bond0
cat /proc/net/bonding/bond0 || true
