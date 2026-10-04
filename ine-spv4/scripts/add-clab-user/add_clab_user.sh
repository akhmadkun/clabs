#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="${1:-./lab_configs}"

# ============================================================
# USER CONFIG
# ============================================================
# Sesuaikan credential ini dengan credential yang memang dipakai
# image/containerlab lu.
#
# Contoh:
#   username clab
#    group root-lr
#    password 0 clab@123
#
# Kalau credential lu beda, ubah bagian ini saja.
# ============================================================

read -r -d '' CLAB_CONFIG <<'EOF' || true
username clab
 group root-lr
 group cisco-support
 secret clab@123
!
EOF

echo "Scanning: $BASE_DIR"
echo

count=0
modified=0
skipped=0

while IFS= read -r -d '' file; do
    ((count+=1))

    # Skip kalau username clab sudah ada


    # Backup
    cp "$file" "$file.bak"

    # Insert setelah hostname block
    tmp="$(mktemp)"

    awk -v clab="$CLAB_CONFIG" '
    BEGIN {
        inserted = 0
    }

    {
        print

        if (!inserted && $0 ~ /^hostname[[:space:]]+/) {
            print "!"
            print clab
            inserted = 1
        }
    }

    END {
        if (!inserted) {
            print "!"
            print clab
        }
    }
    ' "$file" > "$tmp"

    mv "$tmp" "$file"

    echo "[MOD ] $file"
    ((modified+=1))

done < <(find "$BASE_DIR" -type f -name '*.cfg' -print0)

echo
echo "======================================"
echo "Processed : $count"
echo "Modified  : $modified"
echo "Skipped   : $skipped"
echo "======================================"
echo
echo "Backup files created as *.cfg.bak"
