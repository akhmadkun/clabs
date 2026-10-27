#!/usr/bin/env bash
set -euo pipefail

configure_host() {
  local node="$1" address="$2" gateway="$3"
  local container="clab-ospf003-${node}"
  docker exec "$container" sh -c "ip link set eth1 up; ip -4 addr flush dev eth1; ip addr add ${address} dev eth1; ip route replace 10.1.1.0/24 via ${gateway}; ip route replace 192.168.0.0/16 via ${gateway}"
  printf 'Configured %-5s eth1 %-18s gateway %s\n' "$node" "$address" "$gateway"
}

configure_host ep16 192.168.16.2/30 192.168.16.1
configure_host ep17 192.168.17.2/24 192.168.17.1
configure_host ep18 192.168.18.2/23 192.168.18.1
