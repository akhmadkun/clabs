#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
containerlab destroy -t lab-002.clab.yml
printf '\nThe external host bridge br-univ is intentionally left in place.\n'
