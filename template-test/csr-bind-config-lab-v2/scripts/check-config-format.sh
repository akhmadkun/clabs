#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
rc=0

while IFS= read -r -d '' f; do
  echo "Checking $f"
  if ! grep -q '^version ' "$f"; then
    echo "  ERROR: missing version line" >&2; rc=1
  fi
  if ! tail -n 1 "$f" | grep -qx 'end'; then
    echo "  ERROR: last line must be exactly 'end'" >&2; rc=1
  fi
  if grep -nE '^ (interface|router|vrf|line|username|ip )' "$f" >/dev/null 2>&1; then
    :
  fi
done < <(find "$root/configs" -type f -name '*.cfg' -print0 | sort -z)

exit "$rc"
