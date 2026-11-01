#!/usr/bin/env bash
set -euo pipefail

mkdir -p /srv/ftp/archive /var/log/sys101 /run/sshd
chown -R lab:lab /srv/ftp/archive
ssh-keygen -A
exec /usr/bin/supervisord -c /etc/supervisord.conf
