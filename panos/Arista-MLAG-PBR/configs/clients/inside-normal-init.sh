#!/usr/bin/env bash
set -eu
sleep 2
ip link set eth1 up
ip addr replace 10.100.100.11/24 dev eth1
ip route add 0.0.0.0/0 via 10.100.100.1 dev eth1
ip -br addr show eth1
