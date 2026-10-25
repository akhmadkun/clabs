#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
containerlab destroy -t lab-004.clab.yml
printf '
The external host bridge br-univ is intentionally left in place.
'
