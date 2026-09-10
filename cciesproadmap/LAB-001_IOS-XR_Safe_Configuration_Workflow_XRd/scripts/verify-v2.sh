#!/usr/bin/env bash
#
# CCIE-SP Roadmap — LAB-001 verifier
# Platform: Cisco XRd control-plane
#
# Expected topology:
#   CLIENT1 --- R1 --- R2 --- CLIENT2
#
# Addressing:
#   R1 Lo0             10.255.0.1/32
#   R1 Gi0/0/0/0       192.0.2.1/24
#   R1 Gi0/0/0/1       10.0.12.1/30
#   R2 Lo0             10.255.0.2/32
#   R2 Gi0/0/0/0       10.0.12.2/30
#   R2 Gi0/0/0/1       198.51.100.1/24
#   CLIENT1             192.0.2.2/24
#   CLIENT2             198.51.100.2/24
#
# Expected static routes:
#   R1: 198.51.100.0/24 via 10.0.12.2
#   R2: 192.0.2.0/24 via 10.0.12.1
#

set -u

PASS=0
FAIL=0

pass() {
    printf 'PASS: %s\n' "$1"
    PASS=$((PASS + 1))
}

fail() {
    printf 'FAIL: %s\n' "$1"
    if [[ -n "${2:-}" ]]; then
        printf '      %s\n' "$2"
    fi
    FAIL=$((FAIL + 1))
}

# Find a running container by node name.
# Works with both "r1" and normal containerlab names such as
# "clab-cciesp-lab001-r1".
find_container() {
    local node="$1"
    docker ps --format '{{.Names}}' 2>/dev/null |
        awk -v n="$node" '$0 == n || $0 ~ ("-" n "$") { print; exit }'
}

R1="$(find_container r1)"
R2="$(find_container r2)"
CLIENT1="$(find_container client1)"
CLIENT2="$(find_container client2)"

check_container() {
    local node="$1"
    local container="$2"

    if [[ -n "$container" ]]; then
        pass "$node container is running ($container)"
    else
        fail "$node container is running" "No running container ending in -$node was found"
    fi
}

check_container "R1" "$R1"
check_container "R2" "$R2"
check_container "CLIENT1" "$CLIENT1"
check_container "CLIENT2" "$CLIENT2"

# Execute a command through XRd's ZTP helper.
# Important: the IOS XR command itself contains NO "| grep".
# grep/regex processing is done by this host-side Bash script.
xr_cmd() {
    local container="$1"
    local command="$2"

    docker exec "$container" bash -lc \
        "source /pkg/bin/ztp_helper.sh >/dev/null 2>&1 && xrcmd \"$command\"" \
        2>/dev/null
}

check_xr() {
    local container="$1"
    local command="$2"
    local regex="$3"
    local description="$4"
    local output

    if [[ -z "$container" ]]; then
        fail "$description" "Router container is not running"
        return
    fi

    output="$(xr_cmd "$container" "$command" || true)"

    if printf '%s\n' "$output" | grep -Eq "$regex"; then
        pass "$description"
    else
        fail "$description" "Command: $command | Pattern: $regex"
    fi
}

check_linux_ping() {
    local container="$1"
    local destination="$2"
    local description="$3"

    if [[ -z "$container" ]]; then
        fail "$description" "Client container is not running"
        return
    fi

    if docker exec "$container" ping -c 3 -W 2 "$destination" >/dev/null 2>&1; then
        pass "$description"
    else
        fail "$description" "ping $destination from $container failed"
    fi
}

echo "CCIE-SP LAB-001 verification"
echo "============================"

echo
echo "[1] Router interface state"

check_xr "$R1" \
    "show ipv4 interface brief" \
    'GigabitEthernet0/0/0/0[[:space:]]+192\.0\.2\.1[[:space:]]+Up[[:space:]]+Up' \
    "R1 Gi0/0/0/0 is 192.0.2.1 and Up/Up"

check_xr "$R1" \
    "show ipv4 interface brief" \
    'GigabitEthernet0/0/0/1[[:space:]]+10\.0\.12\.1[[:space:]]+Up[[:space:]]+Up' \
    "R1 Gi0/0/0/1 is 10.0.12.1 and Up/Up"

check_xr "$R1" \
    "show ipv4 interface brief" \
    'Loopback0[[:space:]]+10\.255\.0\.1[[:space:]]+Up[[:space:]]+Up' \
    "R1 Loopback0 is 10.255.0.1 and Up/Up"

check_xr "$R2" \
    "show ipv4 interface brief" \
    'GigabitEthernet0/0/0/0[[:space:]]+10\.0\.12\.2[[:space:]]+Up[[:space:]]+Up' \
    "R2 Gi0/0/0/0 is 10.0.12.2 and Up/Up"

check_xr "$R2" \
    "show ipv4 interface brief" \
    'GigabitEthernet0/0/0/1[[:space:]]+198\.51\.100\.1[[:space:]]+Up[[:space:]]+Up' \
    "R2 Gi0/0/0/1 is 198.51.100.1 and Up/Up"

check_xr "$R2" \
    "show ipv4 interface brief" \
    'Loopback0[[:space:]]+10\.255\.0\.2[[:space:]]+Up[[:space:]]+Up' \
    "R2 Loopback0 is 10.255.0.2 and Up/Up"

echo
echo "[2] Static routing"

check_xr "$R1" \
    "show route 198.51.100.0/24" \
    '198\.51\.100\.0/24' \
    "R1 has a route to CLIENT2 LAN"

check_xr "$R1" \
    "show route 198.51.100.0/24" \
    '10\.0\.12\.2' \
    "R1 resolves CLIENT2 LAN through 10.0.12.2"

check_xr "$R2" \
    "show route 192.0.2.0/24" \
    '192\.0\.2\.0/24' \
    "R2 has a route to CLIENT1 LAN"

check_xr "$R2" \
    "show route 192.0.2.0/24" \
    '10\.0\.12\.1' \
    "R2 resolves CLIENT1 LAN through 10.0.12.1"

echo
echo "[3] Router-to-router reachability"

check_xr "$R1" \
    "ping 10.0.12.2 source 10.0.12.1 count 3" \
    'Success rate is 100 percent|!!!' \
    "R1 can ping R2 across the transit link"

check_xr "$R2" \
    "ping 10.0.12.1 source 10.0.12.2 count 3" \
    'Success rate is 100 percent|!!!' \
    "R2 can ping R1 across the transit link"

echo
echo "[4] End-to-end client reachability"

check_linux_ping "$CLIENT1" "198.51.100.2" \
    "CLIENT1 can reach CLIENT2"

check_linux_ping "$CLIENT2" "192.0.2.2" \
    "CLIENT2 can reach CLIENT1"

echo
echo "============================"
printf 'RESULT: %d PASS, %d FAIL\n' "$PASS" "$FAIL"

if (( FAIL > 0 )); then
    exit 1
fi

exit 0
