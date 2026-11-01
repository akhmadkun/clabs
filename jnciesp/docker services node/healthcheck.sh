#!/usr/bin/env bash
set -euo pipefail
pgrep chronyd >/dev/null
pgrep dnsmasq >/dev/null
pgrep -f 'radiusd|freeradius' >/dev/null
pgrep rsyslogd >/dev/null
pgrep sshd >/dev/null
pgrep vsftpd >/dev/null
