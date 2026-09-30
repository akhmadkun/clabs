#!/usr/bin/env bash
set -u
LAB="palo-arista-mlag-pbr-poc"
A1="clab-${LAB}-arista-01"
A2="clab-${LAB}-arista-02"
INP="clab-${LAB}-mt-inside-pbr"
INN="clab-${LAB}-mt-inside-normal"
OUT="clab-${LAB}-mt-outside"

echo "=== container state ==="
docker ps --filter "name=${A1}" --filter "name=${A2}" --filter "name=${INP}" --filter "name=${INN}" --filter "name=${OUT}" --format 'table {{.Names}}\t{{.Status}}'

echo
echo "=== ARISTA-01 ==="
docker exec "${A1}" bash -lc 'Cli -c "show mlag"; echo "---"; Cli -c "show mlag interfaces"; echo "---"; Cli -c "show port-channel summary"; echo "---"; Cli -c "show lacp neighbor"'

echo
echo "=== ARISTA-02 ==="
docker exec "${A2}" bash -lc 'Cli -c "show mlag"; echo "---"; Cli -c "show mlag interfaces"; echo "---"; Cli -c "show port-channel summary"; echo "---"; Cli -c "show lacp neighbor"'

echo
echo "=== clients ==="
docker exec "${INP}" ip -br addr show eth1
docker exec "${INN}" ip -br addr show eth1
docker exec "${OUT}" ip -br addr show eth1

echo
echo "=== PA subinterfaces ==="
docker exec "${INP}" ping -c 3 -W 2 10.100.100.254 || true
docker exec "${OUT}" ping -c 3 -W 2 10.200.200.254 || true

echo
echo "=== selected flow ==="
docker exec "${INP}" ping -c 5 -W 2 10.200.200.10 || true

echo
echo "=== non-selected flow ==="
docker exec "${INN}" ping -c 5 -W 2 10.200.200.10 || true

echo
echo "Manual checks:"
echo "  show class-map type pbr"
echo "  show policy-map type pbr"
echo "  show ip access-lists PBR-FWD"
echo "  show ip access-lists PBR-REV"
echo "  PA Monitor > Traffic"
