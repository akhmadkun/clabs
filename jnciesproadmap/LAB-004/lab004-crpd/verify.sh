#!/usr/bin/env bash
set -euo pipefail

for n in r1 r2 r3 r4; do
  echo "===== $n ====="
  docker exec -i "clab-lab004-crpd-$n" cli -c 'show interfaces terse'
  docker exec -i "clab-lab004-crpd-$n" cli -c 'show ospf neighbor'
  docker exec -i "clab-lab004-crpd-$n" cli -c 'show ldp session'
  docker exec -i "clab-lab004-crpd-$n" cli -c 'show route protocol ospf'
  docker exec -i "clab-lab004-crpd-$n" cli -c 'show route protocol bgp'
done

echo "===== CLIENT -> SERVER ====="
docker exec clab-lab004-crpd-client1 ping -c 3 198.51.100.10
