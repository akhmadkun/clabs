#!/usr/bin/env bash
set -u

LAB="palo-nexus-vpc-pbr-poc"
N1="clab-${LAB}-n9k-01"
N2="clab-${LAB}-n9k-02"
INP="clab-${LAB}-mt-inside-pbr"
INN="clab-${LAB}-mt-inside-normal"
OUT="clab-${LAB}-mt-outside"

echo "=============================================================="
echo "POC-002 — Nexus vPC + PA AE + selective PBR"
echo "=============================================================="

echo
echo "[1] Container state"
docker ps   --filter "name=${N1}"   --filter "name=${N2}"   --filter "name=${INP}"   --filter "name=${INN}"   --filter "name=${OUT}"   --format 'table {{.Names}}	{{.Status}}'

echo
echo "[2] N9K-01"
docker exec "${N1}" bash -lc '
  vsh -c "show vpc brief"
  echo "---"
  vsh -c "show port-channel summary"
  echo "---"
  vsh -c "show lacp neighbor"
'

echo
echo "[3] N9K-02"
docker exec "${N2}" bash -lc '
  vsh -c "show vpc brief"
  echo "---"
  vsh -c "show port-channel summary"
  echo "---"
  vsh -c "show lacp neighbor"
'

echo
echo "[4] Client IPs"
docker exec "${INP}" ip -br addr show eth1
docker exec "${INN}" ip -br addr show eth1
docker exec "${OUT}" ip -br addr show eth1

echo
echo "[5] Reach PA INSIDE subinterface"
docker exec "${INP}" ping -c 3 -W 2 10.100.100.254 || true

echo
echo "[6] Reach PA OUTSIDE subinterface"
docker exec "${OUT}" ping -c 3 -W 2 10.200.200.254 || true

echo
echo "[7] Selected flow"
docker exec "${INP}" ping -c 5 -W 2 10.200.200.10 || true

echo
echo "[8] Non-selected flow"
docker exec "${INN}" ping -c 5 -W 2 10.200.200.10 || true

echo
echo "Manual PA/PBR checks:"
echo "  show ip policy"
echo "  show route-map PBR-TO-PA-FWD pbr-statistics"
echo "  show route-map PBR-TO-PA-REV pbr-statistics"
echo "  PA Monitor > Traffic"
