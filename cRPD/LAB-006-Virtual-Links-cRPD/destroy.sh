#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
containerlab destroy -t lab-006.clab.yml
printf '\nLAB-006 containers removed. External br-univ was not removed.\n'
