#!/usr/bin/env bash
set -euo pipefail

run_cli() {
  local node="$1" command="$2"
  printf '\n===== %s : %s =====\n' "$node" "$command"
  docker exec "clab-ospf003-${node}" cli -c "$command"
}

printf '\nNOTE: results vary depending on which tasks have been completed.\n'
for node in r1 r2 r3 r4; do
  run_cli "$node" 'show ospf neighbor'
done
for node in r1 r2 r3 r4; do
  run_cli "$node" 'show ospf route'
done
run_cli r1 'show ospf database external'
run_cli r2 'show ospf database external'
run_cli r3 'show ospf database external'
run_cli r4 'show ospf database external'
run_cli r4 'show route protocol static'
for node in ep16 ep17 ep18; do
  printf '\n===== %s address =====\n' "$node"
  docker exec "clab-ospf003-${node}" ip -brief address show dev eth1
done
