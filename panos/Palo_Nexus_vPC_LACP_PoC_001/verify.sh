#!/usr/bin/env bash
set -u

LAB="palo-nexus-vpc-lacp-poc"
N1="clab-${LAB}-n9k-01"
N2="clab-${LAB}-n9k-02"
IN="clab-${LAB}-mt-inside"
OUT="clab-${LAB}-mt-outside"

echo "==============================================================="
echo "POC-001 — Palo + Nexus vPC/LACP verification"
echo "==============================================================="

echo
echo "[1] Container state"
docker ps --filter "name=${N1}" --filter "name=${N2}" \
          --filter "name=${IN}" --filter "name=${OUT}" \
          --format 'table {{.Names}}\t{{.Status}}'

echo
echo "[2] N9K-01"
docker exec "${N1}" bash -lc '
  echo "--- show vpc brief ---"
  vsh -c "show vpc brief"
  echo "--- show peer keepalive ---"
  vsh -c "show vpc peer-keepalive"
  echo "--- show port-channel summary ---"
  vsh -c "show port-channel summary"
  echo "--- show lacp neighbor ---"
  vsh -c "show lacp neighbor"
'

echo
echo "[3] N9K-02"
docker exec "${N2}" bash -lc '
  echo "--- show vpc brief ---"
  vsh -c "show vpc brief"
  echo "--- show peer keepalive ---"
  vsh -c "show vpc peer-keepalive"
  echo "--- show port-channel summary ---"
  vsh -c "show port-channel summary"
  echo "--- show lacp neighbor ---"
  vsh -c "show lacp neighbor"
'

echo
echo "[4] MT-INSIDE"
docker exec "${IN}" bash -lc '
  ip -br addr show bond0
  echo "--- bond ---"
  cat /proc/net/bonding/bond0
'

echo
echo "[5] MT-OUTSIDE"
docker exec "${OUT}" bash -lc '
  ip -br addr show bond0
  echo "--- bond ---"
  cat /proc/net/bonding/bond0
'

echo
echo "[6] INSIDE gateway"
docker exec "${IN}" ping -c 3 -W 2 10.100.100.1 || true

echo
echo "[7] OUTSIDE gateway"
docker exec "${OUT}" ping -c 3 -W 2 10.200.200.1 || true

echo
echo "[8] End-to-end through PA"
docker exec "${IN}" ping -c 5 -W 2 10.200.200.10 || true

echo
echo "==============================================================="
echo "PA verification (run on PA-VM CLI):"
echo "  show interface ae1"
echo "  show interface ae2"
echo "  show lacp aggregate-ethernet ae1"
echo "  show lacp aggregate-ethernet ae2"
echo "And check Monitor > Traffic for the allowed session."
echo "==============================================================="
