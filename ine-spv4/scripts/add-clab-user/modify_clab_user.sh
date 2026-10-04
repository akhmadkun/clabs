#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="${1:-./lab_configs}"

count=0
modified=0
skipped=0

while IFS= read -r -d '' file; do
    ((count+=1))

    tmp="$(mktemp)"

    awk '
    BEGIN {
        clab_seen = 0
        skip_block = 0
    }

    # Skip duplicate username clab block
    skip_block {
        if ($0 ~ /^![[:space:]]*$/) {
            skip_block = 0
        }
        next
    }

    # Detect username clab
    $0 ~ /^[[:space:]]*username[[:space:]]+clab([[:space:]]|$)/ {
        if (clab_seen == 0) {
            # Keep the FIRST username clab block
            print
            clab_seen = 1
        } else {
            # Delete subsequent username clab blocks
            skip_block = 1
        }
        next
    }

    {
        print
    }
    ' "$file" > "$tmp"

    # Check whether anything changed
    if cmp -s "$file" "$tmp"; then
        echo "[SKIP] $file"
        rm -f "$tmp"
        ((skipped+=1))
    else
        cp "$file" "$file.bak"
        mv "$tmp" "$file"

        echo "[MOD ] $file"
        ((modified+=1))
    fi

done < <(find "$BASE_DIR" -type f -name '*.cfg' -print0)

echo
echo "======================================"
echo "Processed : $count"
echo "Modified  : $modified"
echo "Skipped   : $skipped"
echo "======================================"
echo
echo "Backup files created as *.cfg.bak"
