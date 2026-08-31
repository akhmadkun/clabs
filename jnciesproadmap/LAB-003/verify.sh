#!/usr/bin/env bash

set -u

failures=0

pass() {
    printf 'PASS: %s\n' "$1"
}

fail() {
    printf 'FAIL: %s\n' "$1"
    failures=$((failures + 1))
}

check_container() {
    local node="$1"
    local state

    state=$(docker inspect -f '{{.State.Running}}' "$node" 2>/dev/null || true)
    if [[ "$state" == "true" ]]; then
        pass "$node container is running"
    else
        fail "$node container is not running"
    fi
}

check_ping() {
    local target="$1"
    local label="$2"

    if docker exec client1 ping -c 2 -W 2 "$target" >/dev/null 2>&1; then
        pass "$label ($target) is reachable from client1"
    else
        fail "$label ($target) is not reachable from client1"
    fi
}

printf 'LAB-003 verification\n'

for node in r1 r2 r3 r4 client1; do
    check_container "$node"
done

check_ping 192.168.30.1 "R1 client-facing interface"
check_ping 10.0.12.2 "R2 link interface"
check_ping 10.0.23.2 "R3 link interface"
check_ping 10.0.34.2 "R4 link interface"
check_ping 10.255.0.1 "R1 loopback"
check_ping 10.255.0.2 "R2 loopback"
check_ping 10.255.0.3 "R3 loopback"
check_ping 10.255.0.4 "R4 loopback"

if (( failures == 0 )); then
    printf '\nRESULT: PASS\n'
    exit 0
fi

printf '\nRESULT: FAIL (%d check(s) failed)\n' "$failures"
exit 1
