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
    local source="$1"
    local target="$2"
    local label="$3"

    if docker exec "$source" ping -c 3 -W 2 "$target" >/dev/null 2>&1; then
        pass "$label"
    else
        fail "$label"
    fi
}

check_cli() {
    local node="$1"
    local command="$2"
    local pattern="$3"
    local label="$4"
    local output

    output=$(docker exec "$node" cli -c "$command" 2>/dev/null || true)
    if grep -Eq "$pattern" <<<"$output"; then
        pass "$label"
    else
        fail "$label"
    fi
}

printf 'LAB-004 verification\n'

for node in r1 r2 r3 r4 client1 server1; do
    check_container "$node"
done

check_ping client1 192.168.40.1 "R1 client gateway is reachable"
check_ping client1 10.255.4.4 "R4 loopback is reachable from client1"
check_ping client1 198.51.100.10 "server1 is reachable end to end"
check_ping server1 192.168.40.10 "client1 is reachable in the reverse direction"

check_cli r1 "show ospf neighbor" "10\\.0\\.12\\.2.*Full" "R1-R2 OSPF adjacency is Full"
check_cli r1 "show ospf neighbor" "10\\.0\\.13\\.2.*Full" "R1-R3 OSPF adjacency is Full"
check_cli r1 "show ldp session" "10\\.255\\.4\\.2.*Operational" "R1-R2 LDP session is operational"
check_cli r1 "show ldp session" "10\\.255\\.4\\.3.*Operational" "R1-R3 LDP session is operational"
check_cli r1 "show bgp summary" "10\\.255\\.4\\.4.*Establ" "R1-R4 iBGP session is Established"
check_cli r1 "show route 198.51.100.0/24 exact" "BGP/170" "R1 has the server LAN as a BGP route"
check_cli r1 "show route table inet.3 10.255.4.4/32 exact" "LDP/9" "R1 resolves R4 through an LDP route in inet.3"

if (( failures == 0 )); then
    printf '\nRESULT: PASS\n'
    exit 0
fi

printf '\nRESULT: FAIL (%d check(s) failed)\n' "$failures"
exit 1
