#!/usr/bin/env bash
set -euo pipefail

fail=0
ok(){ printf '[OK] %s\n' "$*"; }
bad(){ printf '[FAIL] %s\n' "$*"; fail=1; }

command -v docker >/dev/null 2>&1 || bad "docker is not installed"
command -v containerlab >/dev/null 2>&1 || bad "containerlab is not installed"

if command -v ip >/dev/null 2>&1; then
  ip link show virbr0 >/dev/null 2>&1 && ok "virbr0 exists" || bad "virbr0 is not present"
else
  bad "host ip command is not available"
fi

if (( fail )); then exit 1; fi

printf '%s\n' '--- checking public AAA image ---'
docker pull adosztal/aaa:latest >/dev/null
ok "pulled adosztal/aaa:latest"

docker run --rm --entrypoint /bin/sh adosztal/aaa:latest -c '
  set -eu
  command -v ip >/dev/null
  command -v ifconfig >/dev/null
  command -v ss >/dev/null || command -v netstat >/dev/null
  command -v freeradius >/dev/null || command -v radiusd >/dev/null
  command -v tac_plus >/dev/null || command -v tac_plus-ng >/dev/null
  echo "AAA image tool check passed"
'
ok "AAA image contains required networking and AAA binaries"

printf '%s\n' '--- checking topology ---'
containerlab inspect -t fnd103-aaa.clab.yml >/dev/null
ok "topology schema/inspect passed"

printf '%s\n' 'PRE-FLIGHT PASSED'
