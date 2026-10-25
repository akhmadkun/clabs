#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
containerlab deploy -t lab-001.clab.yml
printf '\nNext step: ./configure-hosts.sh\n'
