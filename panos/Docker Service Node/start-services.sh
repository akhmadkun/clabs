#!/bin/bash
set -u -o pipefail

CONFIG_ROOT="${FND_CONFIG_ROOT:-/etc/fnd-services}"
ENABLED_FILE="${CONFIG_ROOT}/enabled"
SERVICE_IP="${SERVICE_IP:-192.168.121.20}"
IFACE="${SERVICE_IFACE:-eth0}"

log() { printf '[fnd-services] %s\n' "$*"; }

enabled() {
    local svc="$1"
    [[ -f "$ENABLED_FILE" ]] && grep -Eq "^[[:space:]]*${svc}([[:space:]]|$)" "$ENABLED_FILE"
}

wait_for_iface() {
    for _ in $(seq 1 120); do
        if ip link show "$IFACE" >/dev/null 2>&1; then
            ip link set "$IFACE" up >/dev/null 2>&1 || true
            if ip -4 addr show dev "$IFACE" | grep -q "${SERVICE_IP}/"; then
                return 0
            fi
        fi
        sleep 1
    done
    log "ERROR: ${IFACE} with ${SERVICE_IP} was not ready"
    return 1
}

prepare_runtime() {
    mkdir -p /run/sshd /var/run/sshd /var/log/fnd-services /var/lib/dnsmasq /srv/tftp /var/www/html
    ssh-keygen -A >/dev/null 2>&1 || true

    # Keep FreeRADIUS package config writable while host-mounted lab files stay read-only.
    if [[ -f "${CONFIG_ROOT}/radius/clients.conf" ]]; then
        cp "${CONFIG_ROOT}/radius/clients.conf" /etc/freeradius/3.0/clients.conf
    fi
    if [[ -f "${CONFIG_ROOT}/radius/authorize" ]]; then
        cp "${CONFIG_ROOT}/radius/authorize" /etc/freeradius/3.0/mods-config/files/authorize
    fi
}

start_one() {
    local svc="$1"
    shift
    log "starting ${svc}"
    if ! "$@"; then
        log "ERROR: ${svc} failed to start"
        return 1
    fi
    return 0
}

wait_for_iface || exit 1
prepare_runtime
printf 'root:lab\n' | chpasswd

# Start each enabled service. A failed service is recorded but does not kill the
# container, allowing verify.sh and troubleshooting to inspect the failure.
if enabled dns; then
    start_one dns dnsmasq --conf-file="${CONFIG_ROOT}/dns/dnsmasq.conf" --pid-file=/run/dnsmasq.pid || true
fi

if enabled ntp; then
    start_one ntp chronyd -d -x -f "${CONFIG_ROOT}/ntp/chrony.conf" \
        >>/var/log/fnd-services/chronyd.log 2>&1 &
fi

if enabled ssh; then
    start_one ssh /usr/sbin/sshd -D -e -f "${CONFIG_ROOT}/ssh/sshd_config" \
        >>/var/log/fnd-services/sshd.log 2>&1 &
fi

if enabled syslog; then
    start_one syslog rsyslogd -n -f "${CONFIG_ROOT}/syslog/rsyslog.conf" \
        >>/var/log/fnd-services/rsyslog.log 2>&1 &
fi

if enabled http; then
    start_one http nginx -c "${CONFIG_ROOT}/nginx/nginx.conf" -g 'daemon off;' \
        >>/var/log/fnd-services/nginx.log 2>&1 &
fi

if enabled snmp; then
    start_one snmp snmpd -f -Lo -C -c "${CONFIG_ROOT}/snmp/snmpd.conf" \
        >>/var/log/fnd-services/snmpd.log 2>&1 &
fi

if enabled radius; then
    start_one radius freeradius -f -l stdout \
        >>/var/log/fnd-services/freeradius.log 2>&1 &
fi

if enabled tftp; then
    start_one tftp /usr/sbin/in.tftpd --foreground --secure --address "${SERVICE_IP}:69" /srv/tftp \
        >>/var/log/fnd-services/tftpd.log 2>&1 &
fi

if enabled dhcp && [[ "${ALLOW_DHCP:-false}" == "true" ]]; then
    log "starting DHCP because ALLOW_DHCP=true"
    dnsmasq --conf-file="${CONFIG_ROOT}/dns/dhcp-dnsmasq.conf" --pid-file=/run/dnsmasq-dhcp.pid || \
        log "ERROR: DHCP failed to start"
elif enabled dhcp; then
    log "DHCP is enabled in the manifest but ALLOW_DHCP is not true; DHCP will not start"
fi

log "enabled services from ${ENABLED_FILE}:"
if [[ -f "$ENABLED_FILE" ]]; then
    grep -vE '^[[:space:]]*(#|$)' "$ENABLED_FILE" || true
fi

exec tail -f /dev/null
