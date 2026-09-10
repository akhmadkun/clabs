#!/usr/bin/env bash
set -u

fail=0
password=${LAB001_PASSWORD:-clab@123}

pass() { printf 'PASS: %s\n' "$1"; }
fail_check() { printf 'FAIL: %s\n' "$1"; fail=1; }

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'ERROR: required command not found: %s\n' "$1" >&2
    exit 2
  fi
}

# Only the IOS XR command runs inside the container. Unix filters are applied
# by check_xr() on the host after the complete router output is captured.
xr() {
  local node=$1
  local command=$2

  if docker exec "$node" test -x /pkg/bin/xr_cli >/dev/null 2>&1; then
    docker exec "$node" /pkg/bin/xr_cli "$command"
    return
  fi

  docker exec "$node" bash -lc \
    'source /pkg/bin/ztp_helper.sh && xrcmd "$1"' _ "$command"
}

show_failure_output() {
  local command=$1
  local output=$2

  printf '      XR command: %s\n' "$command"
  if [[ -n $output ]]; then
    printf '%s\n' "$output" | sed -n '1,12{s/^/      | /;p;}'
  else
    printf '      | <no output>\n'
  fi
}

check_xr() {
  local label=$1
  local node=$2
  local command=$3
  local pattern=$4
  local output
  local rc

  output=$(xr "$node" "$command" 2>&1)
  rc=$?

  if [[ $rc -eq 0 ]] && grep -Eiq -- "$pattern" <<<"$output"; then
    pass "$label"
  else
    fail_check "$label"
    printf '      executor exit code: %s\n' "$rc"
    show_failure_output "$command" "$output"
  fi
}

check_container() {
  local node=$1
  local state

  state=$(docker inspect -f '{{.State.Running}}' "$node" 2>/dev/null || true)
  if [[ $state == true ]]; then
    pass "$node container is running"
  else
    fail_check "$node container is running"
  fi
}

check_ssh() {
  local node=$1
  local address=$2

  if sshpass -p "$password" ssh -q \
      -o StrictHostKeyChecking=no \
      -o UserKnownHostsFile=/dev/null \
      -o ConnectTimeout=8 \
      -o ConnectionAttempts=1 \
      clab@"$address" 'show clock' >/dev/null 2>&1; then
    pass "${node^^} SSH login works with the XRd clab account"
  else
    fail_check "${node^^} SSH login works with the XRd clab account"
  fi
}

require_command docker
require_command grep
require_command sed
require_command ssh
require_command sshpass

check_container r1
check_container r2

check_xr 'R1 runs IOS XRd 25.2.1' r1 \
  'show version' 'IOS XR.*25\.2\.1|Version[[:space:]]+25\.2\.1'
check_xr 'R2 runs IOS XRd 25.2.1' r2 \
  'show version' 'IOS XR.*25\.2\.1|Version[[:space:]]+25\.2\.1'

check_ssh r1 172.31.101.11
check_ssh r2 172.31.101.12

check_xr 'R1-R2 data interface is Up/Up on R1' r1 \
  'show interfaces GigabitEthernet0/0/0/0 brief' \
  'GigabitEthernet0/0/0/0.*[[:space:]]Up[[:space:]]+Up([[:space:]]|$)'
check_xr 'R1-R2 data interface is Up/Up on R2' r2 \
  'show interfaces GigabitEthernet0/0/0/0 brief' \
  'GigabitEthernet0/0/0/0.*[[:space:]]Up[[:space:]]+Up([[:space:]]|$)'

check_xr 'R1 reaches R2 over the data link' r1 \
  'ping 10.0.12.2 count 3' \
  'Success rate is (100|9[0-9]|8[0-9]) percent'

check_xr 'R1 final service marker exists' r1 \
  'show running-config interface Loopback100' \
  'ipv4 address[[:space:]]+10\.100\.1\.1([[:space:]]|/)'
check_xr 'R1 data-link address is restored' r1 \
  'show running-config interface GigabitEthernet0/0/0/0' \
  'ipv4 address[[:space:]]+10\.0\.12\.1([[:space:]]|/)'

if [[ $fail -ne 0 ]]; then
  printf 'RESULT: FAIL\n'
  exit 1
fi

printf 'RESULT: PASS\n'
