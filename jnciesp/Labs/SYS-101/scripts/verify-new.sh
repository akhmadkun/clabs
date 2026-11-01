#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
mkdir -p evidence
fail=0

pass() { printf 'PASS  %s\n' "$1"; }
fail_check() { printf 'FAIL  %s\n' "$1"; fail=1; }
run_cli() { docker exec "$1" cli -c "$2" 2>/dev/null; }

#for node in R1 R2 R3 R4 s1; do
for node in r1 r2 s1; do
  if docker inspect -f '{{.State.Running}}' "$node" 2>/dev/null | grep -q true; then pass "$node is running"; else fail_check "$node is not running"; fi
done

if docker inspect -f '{{.State.Health.Status}}' s1 2>/dev/null | grep -q healthy; then pass 's1 services are healthy'; else fail_check 's1 services are not healthy'; fi
docker exec s1 pgrep -f 'radiusd|freeradius' >/dev/null 2>&1 && pass 's1 RADIUS is running' || fail_check 's1 RADIUS is not running'
#docker exec s1 pgrep sshd >/dev/null 2>&1 && pass 's1 SSH/SCP is running' || fail_check 's1 SSH/SCP is not running'

#for node in R1 R2 R3 R4; do
for node in r1 r2 s1; do
  index="${node#R}"
  loopback="192.0.2.$((10 + index))/32"
  out="evidence/${node}-verification.txt"
  {
    run_cli "$node" 'show configuration system | display set'
    run_cli "$node" 'show configuration routing-instances mgmt_junos | display set'
    run_cli "$node" 'show configuration interfaces lo0 | display set'
    run_cli "$node" 'show route table mgmt_junos.inet.0 10.10.10.0/24 exact detail'
    run_cli "$node" 'show ntp associations'
    run_cli "$node" 'show ntp status'
  } > "$out"

  grep -q "set system host-name ${node}" "$out" && pass "$node hostname" || fail_check "$node hostname"
  grep -q 'set system name-server 172.31.1.100 routing-instance mgmt_junos' "$out" && pass "$node DNS via mgmt_junos" || fail_check "$node DNS via mgmt_junos"
  grep -q "set interfaces lo0 unit 0 family inet address ${loopback}" "$out" && pass "$node loopback" || fail_check "$node loopback"
  grep -q 'set system ntp server 172.31.1.100 key 1 routing-instance mgmt_junos' "$out" && pass "$node authenticated NTP via mgmt_junos" || fail_check "$node authenticated NTP via mgmt_junos"
  grep -q 'set system archival configuration routing-instance mgmt_junos' "$out" && grep -q 'scp://lab@172.31.1.100/srv/ftp/archive' "$out" && pass "$node SCP archival" || fail_check "$node SCP archival"
  grep -q 'set system syslog host 172.31.1.100 routing-instance mgmt_junos' "$out" && pass "$node Syslog via mgmt_junos" || fail_check "$node Syslog via mgmt_junos"
  grep -q 'set system login user radius-ops class ops-class' "$out" && grep -q 'set system login user radius-noc class noc-class' "$out" && grep -q 'set system login user remote class read-only' "$out" && pass "$node authorization templates" || fail_check "$node authorization templates"
  grep -q 'set system authentication-order radius' "$out" && grep -q 'set system authentication-order password' "$out" && pass "$node RADIUS with password fallback" || fail_check "$node RADIUS with password fallback"
  grep -q 'set system radius-server 172.31.1.100 routing-instance mgmt_junos' "$out" && pass "$node RADIUS via mgmt_junos" || fail_check "$node RADIUS via mgmt_junos"
  grep -q '10.10.10.0/24' "$out" && grep -q '10.0.0.2' "$out" && pass "$node retained management route" || fail_check "$node retained management route"
done

find services/archive -type f -size +0c | head -1 | grep -q . && pass 'configuration archive received' || fail_check 'configuration archive not received'
find evidence/services -name '*.log' -size +0c | head -1 | grep -q . && pass 'central logs received' || fail_check 'central logs not received'

if [[ "$fail" -eq 0 ]]; then echo 'RESULT: PASS'; else echo 'RESULT: FAIL'; exit 1; fi
