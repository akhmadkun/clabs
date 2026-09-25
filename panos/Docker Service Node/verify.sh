#!/bin/bash
set -u -o pipefail

CONTAINER="${1:-server}"

if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
    echo "[FAIL] container not found: $CONTAINER"
    echo "Usage: ./verify.sh [container-name]"
    exit 1
fi

if [[ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" != "true" ]]; then
    echo "[FAIL] container is not running: $CONTAINER"
    exit 1
fi

docker exec -i "$CONTAINER" /bin/bash -s <<'REMOTE'
set -u -o pipefail

SERVICE_IP="${SERVICE_IP:-192.168.121.20}"
ENABLED_FILE="${FND_CONFIG_ROOT:-/etc/fnd-services}/enabled"

fail=0

ok()    { printf '[ OK ] %s\n' "$1"; }
failx() { printf '[FAIL] %s\n' "$1"; fail=1; }

enabled() {
    grep -Eq "^[[:space:]]*$1([[:space:]]|$)" "$ENABLED_FILE" 2>/dev/null
}

check_proc() {
    local proc="$1"
    if pgrep -x "$proc" >/dev/null 2>&1; then
        ok "$proc running"
    else
        failx "$proc not running"
    fi
}

check_udp() {
    local port="$1"
    local label="$2"
    if ss -H -lun "sport = :${port}" 2>/dev/null | grep -q .; then
        ok "$label UDP/${port} listening"
    else
        failx "$label UDP/${port} not listening"
    fi
}

check_tcp() {
    local port="$1"
    local label="$2"
    if ss -H -ltn "sport = :${port}" 2>/dev/null | grep -q .; then
        ok "$label TCP/${port} listening"
    else
        failx "$label TCP/${port} not listening"
    fi
}

printf '=== Palo Lab Universal Services Verification ===\n'

echo
echo "--- Interface ---"
ip -brief addr show eth0 || true
if ip -4 addr show dev eth0 | grep -q "${SERVICE_IP}/"; then
    ok "service IP ${SERVICE_IP}/24 present"
else
    failx "service IP ${SERVICE_IP}/24 missing"
fi

echo
echo "--- Processes and sockets ---"
if enabled dns; then
    check_proc dnsmasq
    check_udp 53 DNS
    check_tcp 53 DNS
fi

if enabled ntp; then
    check_proc chronyd
    check_udp 123 NTP
fi

if enabled ssh; then
    check_proc sshd
    check_tcp 22 SSH
fi

if enabled syslog; then
    check_proc rsyslogd
    check_udp 514 Syslog
    check_tcp 514 Syslog
fi

if enabled http; then
    check_proc nginx
    check_tcp 80 HTTP
fi

if enabled snmp; then
    check_proc snmpd
    check_udp 161 SNMP
fi

if enabled radius; then
    check_proc freeradius
    check_udp 1812 "RADIUS auth"
    check_udp 1813 "RADIUS acct"
fi

if enabled tftp; then
    check_proc in.tftpd
    check_udp 69 TFTP
fi

echo
echo "--- Listener summary ---"
ss -lntup || true

echo
echo "--- DNS functional tests ---"
if enabled dns; then
    if dig +time=2 +tries=1 +short @"$SERVICE_IP" services.fndlab A | grep -Fxq "$SERVICE_IP"; then
        ok "DNS services.fndlab -> $SERVICE_IP"
    else
        failx "DNS services.fndlab lookup failed"
    fi

    if dig +time=2 +tries=1 +short @"$SERVICE_IP" pa1.fndlab A | grep -Fxq '192.168.121.10'; then
        ok "DNS pa1.fndlab -> 192.168.121.10"
    else
        failx "DNS pa1.fndlab record incorrect or missing"
    fi
fi

echo
echo "--- NTP functional test ---"
if enabled ntp; then
    if chronyc -n tracking >/tmp/fnd-chrony.txt 2>&1; then
        ok "chrony tracking works"
    else
        failx "chrony tracking failed"
    fi
fi

echo
echo "--- SSH functional test ---"
if enabled ssh; then
    if timeout 3 bash -c "</dev/tcp/${SERVICE_IP}/22" >/dev/null 2>&1; then
        ok "TCP/22 reachable"
    else
        failx "TCP/22 not reachable"
    fi
fi

echo
echo "--- HTTP functional test ---"
if curl -fsS --max-time 5 -o /dev/null "http://${SERVICE_IP}/"; then
    ok "HTTP response received"
else
    failx "HTTP request failed"
fi

echo
echo "--- Syslog functional test ---"
if enabled syslog; then
    marker="FNDLAB_VERIFY_$$"
    logger -n "$SERVICE_IP" -P 514 -d "$marker" || true
    sleep 1
    if grep -Fq "$marker" /var/log/fnd-services/remote.log 2>/dev/null; then
        ok "Syslog UDP/514 accepted and recorded"
    else
        failx "Syslog functional test failed"
    fi
fi

echo
echo "--- SNMP functional test ---"
if enabled snmp; then
    if snmpget -v2c -c public -t 2 -r 0 "$SERVICE_IP" 1.3.6.1.2.1.1.1.0 >/tmp/fnd-snmp.txt 2>&1; then
        ok "SNMP query works"
    else
        failx "SNMP query failed"
        sed -n '1,8p' /tmp/fnd-snmp.txt 2>/dev/null || true
    fi
fi

echo
echo "--- RADIUS functional test ---"
if enabled radius; then
    if radtest labuser labpass "$SERVICE_IP" 0 labsecret 0 "$SERVICE_IP" >/tmp/fnd-radius.txt 2>&1 \
       && grep -Fq 'Access-Accept' /tmp/fnd-radius.txt; then
        ok "RADIUS Access-Accept received"
    else
        failx "RADIUS Access-Accept test failed"
        sed -n '1,12p' /tmp/fnd-radius.txt 2>/dev/null || true
    fi
fi

echo
echo "--- TFTP functional test ---"
if enabled tftp; then
    rm -f /tmp/tftp-test.txt
    if timeout 5 tftp "$SERVICE_IP" -c get tftp-test.txt /tmp/tftp-test.txt >/tmp/fnd-tftp.txt 2>&1 \
       && grep -Fq 'Palo Lab Universal Services TFTP test file' /tmp/tftp-test.txt 2>/dev/null; then
        ok "TFTP download works"
    else
        failx "TFTP download failed"
        sed -n '1,12p' /tmp/fnd-tftp.txt 2>/dev/null || true
    fi
fi

echo
echo "--- DHCP configuration ---"
if dnsmasq --test --conf-file=/etc/fnd-services/dns/dhcp-dnsmasq.conf >/tmp/fnd-dhcp.txt 2>&1; then
    ok "DHCP dnsmasq configuration syntax valid"
else
    failx "DHCP dnsmasq configuration syntax invalid"
    sed -n '1,12p' /tmp/fnd-dhcp.txt 2>/dev/null || true
fi

if ss -H -lun 'sport = :67' 2>/dev/null | grep -q .; then
    printf '[INFO] DHCP UDP/67 is active\n'
else
    printf '[INFO] DHCP UDP/67 is inactive (expected on shared virbr1)\n'
fi

echo
echo "--- Installed tools ---"
for tool in dig curl tcpdump nmap nc openssl snmpget radtest tftp traceroute jq; do
    if command -v "$tool" >/dev/null 2>&1; then
        ok "$tool installed"
    else
        failx "$tool missing"
    fi
done

echo
if (( fail == 0 )); then
    echo "=== ALL ENABLED SERVICE TESTS PASSED ==="
else
    echo "=== ONE OR MORE SERVICE TESTS FAILED ==="
fi

exit "$fail"
REMOTE
