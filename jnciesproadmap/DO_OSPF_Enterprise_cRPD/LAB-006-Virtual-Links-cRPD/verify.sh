#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

run_cli() {
  local node="$1" command="$2"
  printf '\n===== %s : %s =====\n' "$node" "$command"
  if ! docker exec "clab-ospf006-${node}" cli -c "$command"; then
    echo "(command failed or this feature/state is not available yet)"
  fi
}

printf '\nNOTE: output varies by task progress. No command configures the routers.\n'
for node in r1 r2 r3 r4 r10; do
  run_cli "$node" 'show ospf neighbor'
done
run_cli r1 'show ospf interface detail'
run_cli r2 'show ospf interface detail'
run_cli r2 'show route 192.168.76.0/24 exact'
run_cli r2 'show route 192.168.77.0/24 exact'
run_cli r2 'show ospf database area 0.0.0.0'
run_cli r2 'show ospf interface vl-10.1.1.10 detail'
run_cli r10 'show ospf interface vl-10.1.1.2 detail'
run_cli r10 'show ospf database area 0.0.0.3'
run_cli r1 'show route 192.168.76.0/24 exact'
run_cli r1 'show route 192.168.77.0/24 exact'
run_cli r3 'show route 192.168.76.0/24 exact'
run_cli r3 'show route 192.168.77.0/24 exact'

for node in ep16 ep17 ep18 ep76 ep77; do
  printf '\n===== %s addresses/routes =====\n' "$node"
  docker exec "clab-ospf006-${node}" ip -brief address show dev eth1
  docker exec "clab-ospf006-${node}" ip route show
done
