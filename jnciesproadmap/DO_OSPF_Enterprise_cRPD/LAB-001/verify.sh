#!/usr/bin/env bash
set -euo pipefail

run_cli() {
  local node="$1" command="$2"
  printf '\n===== %s : %s =====\n' "$node" "$command"
  docker exec "clab-ospf001-${node}" cli -c "$command"
}

for node in r1 r2 r3 r4; do
  run_cli "$node" 'show interfaces terse'
done

for node in r1 r2 r3 r4; do
  run_cli "$node" 'show ospf neighbor'
done

for node in r1 r2 r3 r4; do
  run_cli "$node" 'show route protocol ospf'
done

run_cli r1 'show ospf database area 0.0.0.0'
run_cli r3 'show ospf database area 0.0.0.1'
run_cli r4 'show ospf database area 0.0.0.2'
run_cli r1 'show route 192.168.16.0/21 exact'

printf '\n===== Endpoint connectivity =====\n'
for node in ep16 ep17 ep18; do
  docker exec "clab-ospf001-${node}" ip -brief address show dev eth1
done
