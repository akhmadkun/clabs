#!/usr/bin/env bash
set -euo pipefail

run_cli() {
  local node="$1" command="$2"
  printf '\n===== %s : %s =====\n' "$node" "$command"
  if ! docker exec "clab-ospf005-${node}" cli -c "$command"; then
    echo "(command failed or this table/instance is not configured yet)"
  fi
}

printf '\nNOTE: output depends on which task steps have been completed.\n'
for node in r1 r2 r3 r4 r6 r7 r8 r9; do
  run_cli "$node" 'show ospf neighbor'
done
run_cli r1 'show ospf neighbor instance domain2'
run_cli r1 'show route protocol ospf'
run_cli r1 'show route table domain2.inet.0'
run_cli r2 'show bgp summary'
run_cli r2 'show route protocol bgp'
run_cli r2 'show ospf database external'
run_cli r8 'show bgp summary'
run_cli r8 'show route protocol bgp'
run_cli r8 'show ospf database external'
run_cli r4 'show route protocol ospf'
run_cli r9 'show route protocol ospf'

for node in ep16 ep17 ep18 ep91 ep92; do
  printf '\n===== %s address/routes =====\n' "$node"
  docker exec "clab-ospf005-${node}" ip -brief address show dev eth1
  docker exec "clab-ospf005-${node}" ip route show
 done
