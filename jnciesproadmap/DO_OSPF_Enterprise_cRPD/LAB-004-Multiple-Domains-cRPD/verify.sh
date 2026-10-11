#!/usr/bin/env bash
set -euo pipefail

run_cli() {
  local node="$1" command="$2"
  printf '
===== %s : %s =====
' "$node" "$command"
  if ! docker exec "clab-ospf004-${node}" cli -c "$command"; then
    echo "(command failed or this table/instance is not configured yet)"
  fi
}

printf '
NOTE: output depends on which lab task steps have been completed.
'
for node in r1 r2 r3 r4 r6 r7; do
  run_cli "$node" 'show ospf neighbor'
done
run_cli r1 'show ospf neighbor instance domain2'
run_cli r1 'show route protocol ospf'
run_cli r1 'show route table domain2.inet.0'
run_cli r1 'show ospf database external'
run_cli r2 'show ospf route'
run_cli r6 'show route protocol ospf'
run_cli r7 'show route protocol ospf'
for node in ep16 ep17 ep18; do
  printf '
===== %s address =====
' "$node"
  docker exec "clab-ospf004-${node}" ip -brief address show dev eth1
done
