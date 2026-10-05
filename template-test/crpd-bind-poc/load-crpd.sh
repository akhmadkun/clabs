#!/usr/bin/env bash
set -euo pipefail

LAB_NAME="crpd-bind-poc"
NODE="crpd1"
CONTAINER="clab-${LAB_NAME}-${NODE}"
CONFIG_FILE="${1:-}"

if [[ -z "$CONFIG_FILE" ]]; then
    echo "Usage: $0 lab1.conf|lab2.conf|lab3.conf"
    exit 1
fi

case "$CONFIG_FILE" in
    lab1.conf|lab2.conf|lab3.conf) ;;
    *)
        echo "ERROR: allowed files: lab1.conf, lab2.conf, lab3.conf"
        exit 1
        ;;
esac

if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
    echo "ERROR: container $CONTAINER does not exist."
    echo "Deploy first: sudo containerlab deploy -t topology.clab.yml"
    exit 1
fi

if ! docker inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null | grep -q true; then
    echo "ERROR: container $CONTAINER is not running."
    exit 1
fi

echo "=== Files visible inside cRPD ==="
docker exec "$CONTAINER" ls -la /lab-configs

echo
echo "=== Loading /lab-configs/$CONFIG_FILE ==="

docker exec -i "$CONTAINER" cli <<JUNOS
configure
load override /lab-configs/$CONFIG_FILE
commit
show configuration system host-name
show configuration routing-options router-id
show configuration interfaces lo0
exit
JUNOS
