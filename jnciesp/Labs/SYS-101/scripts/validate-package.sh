#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
fail=0

check_file() {
  if [[ -s "$1" ]]; then printf 'PASS  %s\n' "$1"; else printf 'FAIL  %s\n' "$1"; fail=1; fi
}

for file in topology.clab.yml Makefile README.md \
  configs/R1.conf configs/R2.conf configs/R3.conf configs/R4.conf \
  services/Dockerfile services/supervisord.conf services/sshd_config services/start-sys101.sh \
  scripts/verify.sh docs/SYS-101_TASK-ONLY.pdf \
  docs/SYS-101_SOLUTION-GUIDE.pdf docs/SYS-101_SOLUTION-GUIDE.docx \
  docs/SYS-101_SOLUTION-GUIDE.md topology/SYS-101_TOPOLOGY.png; do
  check_file "$file"
done

grep -q 'prefix: ""' topology.clab.yml || { echo 'FAIL  prefix is not empty'; fail=1; }
grep -q 'enforce-startup-config: true' topology.clab.yml || { echo 'FAIL  startup enforcement missing'; fail=1; }
grep -q 'vrnetlab/juniper_vjunos-router:25.4R1.12' topology.clab.yml || { echo 'FAIL  vJunos-router image name is incorrect'; fail=1; }
grep -q 'ipv4-subnet: 172.31.1.0/24' topology.clab.yml || { echo 'FAIL  management subnet is incorrect'; fail=1; }
if grep -q 'ipv4-gw:' topology.clab.yml; then echo 'FAIL  management gateway must be injected by Containerlab'; fail=1; fi
grep -q 'ghcr.io/srl-labs/network-multitool:latest' services/Dockerfile || { echo 'FAIL  required multitool base image missing'; fail=1; }
grep -q 'chown root:radius /etc/raddb/clients.conf /etc/raddb/users' services/Dockerfile || { echo 'FAIL  RADIUS file ownership fix missing'; fail=1; }
grep -q 'chmod 640 /etc/raddb/clients.conf /etc/raddb/users' services/Dockerfile || { echo 'FAIL  RADIUS file permissions are incorrect'; fail=1; }
grep -q '\[program:sshd\]' services/supervisord.conf || { echo 'FAIL  SSH/SCP service missing'; fail=1; }
grep -q 'Juniper-Local-User-Name := "radius-ops"' services/radius-users || { echo 'FAIL  ops RADIUS authorization mapping missing'; fail=1; }
grep -q 'Juniper-Local-User-Name := "radius-noc"' services/radius-users || { echo 'FAIL  noc RADIUS authorization mapping missing'; fail=1; }
for f in configs/*.conf; do
  grep -q '^system {' "$f" || { echo "FAIL  $f is not hierarchical Junos configuration"; fail=1; }
  if grep -Eq 'fxp0|management-instance|mgmt_junos|0\.0\.0\.0/0' "$f"; then echo "FAIL  $f duplicates Containerlab management configuration"; fail=1; fi
done
if rg -n '10\.10\.1\.|juniper-vjunos-router' topology.clab.yml configs services docs/*.md scripts/verify.sh README.md tools/create_topology.py; then
  echo 'FAIL  stale management addressing or image name remains'; fail=1
fi
if rg -n 'set system ntp boot-server|next-hop 172\.31\.1\.1|ftp://lab' docs/*.md scripts/verify.sh services README.md; then
  echo 'FAIL  stale tested configuration remains'; fail=1
fi

if command -v python3 >/dev/null; then
  python3 - <<'PY'
from pathlib import Path
import yaml
d=yaml.safe_load(Path('topology.clab.yml').read_text())
assert d['prefix'] == ''
assert d['mgmt'] == {'network': 'sys101-mgmt', 'ipv4-subnet': '172.31.1.0/24'}
assert len(d['topology']['nodes']) == 5
assert all(d['topology']['nodes'][r]['enforce-startup-config'] is True for r in ('R1','R2','R3','R4'))
assert [d['topology']['nodes'][r]['mgmt-ipv4'] for r in ('R1','R2','R3','R4','S1')] == ['172.31.1.11','172.31.1.12','172.31.1.13','172.31.1.14','172.31.1.100']
print('PASS  topology YAML structure')
PY
fi

if [[ "$fail" -eq 0 ]]; then echo 'RESULT: PASS'; else echo 'RESULT: FAIL'; exit 1; fi
