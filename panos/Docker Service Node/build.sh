#!/bin/bash
set -euo pipefail
IMAGE="${1:-palo-lab-services:1.4}"

required=(Dockerfile start-services.sh service-data/www/index.html service-data/tftp/tftp-test.txt)
for f in "${required[@]}"; do
    [[ -f "$f" ]] || { echo "[FAIL] build-context file missing: $f"; exit 1; }
done

bash -n start-services.sh
bash -n verify.sh

echo "[ OK ] build context and shell syntax checks passed"
echo "[INFO] building $IMAGE"
docker build --no-cache -t "$IMAGE" .
echo "[ OK ] image built: $IMAGE"
