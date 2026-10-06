#!/usr/bin/env bash
set -u
PA_IP="${PA_IP:-192.168.122.10}"
SSH_PORT="${SSH_PORT:-22}"
echo "=============================================="
echo "FND-102 external management verification"
echo "PA_IP=${PA_IP} SSH_PORT=${SSH_PORT}"
echo "=============================================="
echo
echo "[1] ICMP"
ping -c 2 -W 2 "${PA_IP}" || true
echo
echo "[2] HTTPS TCP/443"
nc -vz -w 3 "${PA_IP}" 443 || true
echo
echo "[3] HTTPS application"
curl -kI --connect-timeout 5 --max-time 8 "https://${PA_IP}" || true
echo
echo "[4] SSH TCP/${SSH_PORT}"
nc -vz -w 3 "${PA_IP}" "${SSH_PORT}" || true
echo
echo "Expected: before and after recovery, 443 and 22 are reachable; during CR-102-B they fail."
echo "This script does not modify the firewall."
