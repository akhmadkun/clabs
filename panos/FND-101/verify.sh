#!/bin/bash
set -u -o pipefail

CONTAINER="${1:-server}"
PA_IP="${PA_IP:-192.168.121.10}"
SERVICE_IP="${SERVICE_IP:-192.168.121.20}"

fail=0
ok(){ printf '[ OK ] %s\n' "$1"; }
bad(){ printf '[FAIL] %s\n' "$1"; fail=1; }

if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
  bad "container not found: $CONTAINER"
  exit 1
fi

if [[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" != "true" ]]; then
  bad "container not running: $CONTAINER"
  exit 1
fi

docker exec -i \
  -e PA_IP="$PA_IP" \
  -e SERVICE_IP="$SERVICE_IP" \
  "$CONTAINER" /bin/bash -s <<'REMOTE'
set -u -o pipefail

fail=0
ok(){ printf '[ OK ] %s\n' "$1"; }
bad(){ printf '[FAIL] %s\n' "$1"; fail=1; }

echo "=== LAB-001 FND-101 Verification ==="

echo
echo "--- Service Node ---"
ip -brief addr show eth0 || true

if ip -4 addr show dev eth0 | grep -q '192.168.121.20/24'; then
  ok "service IP 192.168.121.20/24 present"
else
  bad "service IP missing"
fi

if pgrep -x dnsmasq >/dev/null; then ok "dnsmasq running"; else bad "dnsmasq not running"; fi
if pgrep -x chronyd >/dev/null; then ok "chronyd running"; else bad "chronyd not running"; fi

if ss -H -lun 'sport = :53' | grep -q .; then ok "DNS UDP/53 listening"; else bad "DNS UDP/53 not listening"; fi
if ss -H -ltn 'sport = :53' | grep -q .; then ok "DNS TCP/53 listening"; else bad "DNS TCP/53 not listening"; fi
if ss -H -lun 'sport = :123' | grep -q .; then ok "NTP UDP/123 listening"; else bad "NTP UDP/123 not listening"; fi

echo
echo "--- DNS ---"
if dig +time=2 +tries=1 +short @"$SERVICE_IP" services.fndlab A | grep -Fxq "$SERVICE_IP"; then
  ok "services.fndlab resolves to $SERVICE_IP"
else
  bad "services.fndlab DNS test failed"
fi

if dig +time=2 +tries=1 +short @"$SERVICE_IP" pa1.fndlab A | grep -Fxq "$PA_IP"; then
  ok "pa1.fndlab resolves to $PA_IP"
else
  bad "pa1.fndlab does not resolve to $PA_IP"
fi

echo
echo "--- PA Reachability ---"
if ping -c 2 -W 2 "$PA_IP" >/dev/null 2>&1; then ok "PA IP responds to ICMP"; else bad "PA IP does not respond to ICMP"; fi

if nc -z -w 3 "$PA_IP" 443 >/dev/null 2>&1; then ok "PA HTTPS/443 reachable"; else bad "PA HTTPS/443 not reachable"; fi
if nc -z -w 3 "$PA_IP" 22 >/dev/null 2>&1; then ok "PA SSH/22 reachable"; else bad "PA SSH/22 not reachable"; fi

echo
echo "--- PA HTTPS Application ---"
if curl -ksS --max-time 5 -o /dev/null -w '%{http_code}\n' "https://${PA_IP}/" | grep -Eq '^(200|302|301|401|403)$'; then
  ok "PA HTTPS responds"
else
  bad "PA HTTPS application did not respond"
fi

echo
echo "--- NTP ---"
if chronyc -n tracking >/dev/null 2>&1; then ok "local chrony tracking works"; else bad "local chrony tracking failed"; fi

echo
if (( fail == 0 )); then
  echo "=== LAB-001 SERVICE-SIDE VERIFICATION PASSED ==="
else
  echo "=== LAB-001 VERIFICATION FAILED ==="
fi

exit "$fail"
REMOTE

exit $?
