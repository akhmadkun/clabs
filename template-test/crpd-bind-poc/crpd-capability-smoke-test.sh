#!/usr/bin/env bash
set -u

OUT="/tmp/crpd-capability-$(date +%Y%m%d-%H%M%S).log"

run_cli() {
    local label="$1"
    local cmd="$2"
    printf '\n===== %s =====\n' "$label" | tee -a "$OUT"
    printf '$ %s\n' "$cmd" | tee -a "$OUT"
    timeout 10s cli -c "$cmd" 2>&1 | tee -a "$OUT"
}

echo "cRPD Capability Smoke Test"
echo "Started: $(date)"
echo "Output:  $OUT"

run_cli "VERSION" "show version"
run_cli "LICENSE" "show system license"
run_cli "FEATURE LIST" "show system license feature-list"

tests=(
  "IPv4 route|show route"
  "Forwarding table|show route forwarding-table"
  "IS-IS adjacency|show isis adjacency"
  "IS-IS interfaces|show isis interface"
  "IS-IS database|show isis database"
  "OSPF neighbors|show ospf neighbor"
  "OSPF3 neighbors|show ospf3 neighbor"
  "BGP summary|show bgp summary"
  "BFD sessions|show bfd session"
  "MPLS interfaces|show mpls interface"
  "MPLS LSP|show mpls lsp"
  "LDP sessions|show ldp session"
  "inet.3|show route table inet.3"
  "EVPN database|show evpn database"
  "EVPN status|show evpn instance"
  "Routing-instances|show route instance"
)

for item in "${tests[@]}"; do
    label="${item%%|*}"
    cmd="${item#*|}"
    run_cli "$label" "$cmd"
done

cat <<'EOF2' | tee -a "$OUT"

===== QUICK INTERPRETATION =====
- "unknown command" / "syntax error"  = command is not available in this image/release.
- "license" / "not licensed"           = feature is recognized but blocked by licensing.
- Valid output with an empty table     = command works; the feature simply is not configured/up yet.
- Valid protocol/session output        = strong evidence the feature is usable in the current image.

This test is READ-ONLY: it does not load or commit configuration.
EOF2

echo
echo "Done."
echo "Log saved to: $OUT"
