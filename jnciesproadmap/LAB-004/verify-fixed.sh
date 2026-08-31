#!/usr/bin/env bash

set -u

failures=0

JUNOS_USER="${JUNOS_USER:-admin}"
JUNOS_PASS="${JUNOS_PASS:-admin@123}"

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; failures=$((failures + 1)); }

check_container() {
    local node="$1" state
    state=$(docker inspect -f '{{.State.Running}}' "$node" 2>/dev/null || true)
    [[ "$state" == "true" ]] && pass "$node container is running" || fail "$node container is not running"
}

check_ping() {
    local source="$1" target="$2" label="$3"
    if docker exec "$source" ping -c 3 -W 2 "$target" >/dev/null 2>&1; then
        pass "$label"
    else
        fail "$label"
    fi
}

get_mgmt_ip() {
    local node="$1"
    docker inspect -f '{{range $name,$net := .NetworkSettings.Networks}}{{if $net.IPAddress}}{{$net.IPAddress}}{{"\n"}}{{end}}{{end}}' "$node" 2>/dev/null | head -n1
}

run_cli() {
    local node="$1" command="$2" ip
    ip="$(get_mgmt_ip "$node")"
    if [[ -z "$ip" ]]; then
        printf 'ERROR: unable to determine management IP for %s\n' "$node" >&2
        return 1
    fi

    sshpass -p "$JUNOS_PASS" ssh \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        -o ConnectTimeout=5 \
        -o LogLevel=ERROR \
        "${JUNOS_USER}@${ip}" \
        "cli -c '$command | no-more'"
}

check_cli() {
    local node="$1" command="$2" pattern="$3" label="$4" output rc
    output="$(run_cli "$node" "$command" 2>&1)"
    rc=$?

    if (( rc != 0 )); then
        fail "$label (CLI access failed)"
        printf '      %s\n' "$output"
        return
    fi

    output="${output//$'\r'/}"
    if grep -Eq "$pattern" <<<"$output"; then
        pass "$label"
    else
        fail "$label"
        printf '      Command: %s\n' "$command"
        printf '      Pattern: %s\n' "$pattern"
    fi
}

printf 'LAB-004 verification\n'

if ! command -v sshpass >/dev/null 2>&1; then
    printf 'ERROR: sshpass is required for Junos CLI verification.\n'
    exit 2
fi

for node in r1 r2 r3 r4 client1 server1; do
    check_container "$node"
done

check_ping client1 192.168.40.1 "R1 client gateway is reachable"
check_ping client1 10.255.4.4 "R4 loopback is reachable from client1"
check_ping client1 198.51.100.10 "server1 is reachable end to end"
check_ping server1 192.168.40.10 "client1 is reachable in the reverse direction"

check_cli r1 "show ospf neighbor" '10\.0\.12\.2[[:space:]].*Full' "R1-R2 OSPF adjacency is Full"
check_cli r1 "show ospf neighbor" '10\.0\.13\.2[[:space:]].*Full' "R1-R3 OSPF adjacency is Full"
check_cli r1 "show ldp session" '10\.255\.4\.2[[:space:]].*Operational' "R1-R2 LDP session is operational"
check_cli r1 "show ldp session" '10\.255\.4\.3[[:space:]].*Operational' "R1-R3 LDP session is operational"
check_cli r1 "show bgp summary" '10\.255\.4\.4[[:space:]].*Establ' "R1-R4 iBGP session is Established"
check_cli r1 "show route 198.51.100.0/24 exact" 'BGP/170' "R1 has the server LAN as a BGP route"
check_cli r1 "show route table inet.3 10.255.4.4/32 exact" 'LDP/9' "R1 resolves R4 through an LDP route in inet.3"

if (( failures == 0 )); then
    printf '\nRESULT: PASS\n'
    exit 0
fi

printf '\nRESULT: FAIL (%d check(s) failed)\n' "$failures"
exit 1
