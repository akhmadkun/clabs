LAB-015 — OSPF TIMER MISMATCH, FAILURE DETECTION & RETRANSMISSION
Target: Juniper cRPD crpd:23.4R2-S5.6
Scope: OSPFv2, IPv4, Area 0, R1-R4 diamond, point-to-point links

PURPOSE
This is an outcome-based troubleshooting and change-control lab. A timer change was made on only one endpoint of an adjacency. Diagnose the failed adjacency from operational evidence, restore it, then implement and validate a deliberate lower hello/dead timer profile on that link. An optional extension distinguishes adjacency timers from the per-interface LSA retransmission timer.

CONTENTS
- TASK.txt: challenge only; no set-command recipe.
- SOLUTION-GUIDE.txt: guided fix, exact CLI syntax and cleanup.
- ADDRESS-PLAN.txt: router IDs, loopbacks, VLANs, interfaces and subnets.
- CLEANUP-BEFORE-LAB015.txt: remove config residue from prior labs and preserve the shared underlay.
- PROFILE-MAP.txt: which profile file to load for each router.
- VALIDATION-NOTES.txt: acceptance expectations and limitations.
- REFERENCE.txt: relevant Juniper documentation.
- configs/rN/lab015-rN-baseline.set: clean baseline profile, separately loaded through the mounted directory.
- configs/r3/lab015-r3-incident-start.set: full R3 profile with the seeded timer fault for the opening incident. Use this instead of the R3 baseline profile at the start.
- topology.svg / topology.png: editable vector diagram and preview.

HOW TO USE
1. Stop any other lab currently using VLANs 12, 13, 24, and 34 or these loopback addresses.
2. Read CLEANUP-BEFORE-LAB015.txt first and ensure LAB-014 authentication / LAB-013 overload, SPF, and flood-reduction settings are not left behind.
3. Load the baseline profile for R1, R2, and R4. On R3 load the incident-start profile, not the baseline profile. The `.set` files are manual lab profiles; they are not the Containerlab startup-config and are not applied automatically.
4. Attempt TASK.txt before reading SOLUTION-GUIDE.txt.
5. Save evidence at each phase. Do not treat `commit` or an interface showing desired timer values as sufficient proof by itself.
6. Perform the required clean restore after testing.

The `.set` files are available under each router's mounted `/lab-configs` directory using the existing universal topology. Example file paths are documented in PROFILE-MAP.txt.

TOPOLOGY SAFETY
- Reuse the existing universal Containerlab topology. Do not edit or redeploy its YAML for this lab.
- All parent eth1 interfaces remain connected to the externally managed, pre-existing `br-univ` bridge.
- Do not create, delete, or recreate `br-univ`; do not shut down parent eth1 interfaces.
- Fault injection is by OSPF timer configuration on logical subinterfaces only.

SCOPE NOTE
This lab evaluates control-plane adjacency and RIB behavior. It does not claim packet-forwarding performance in cRPD. Fast Hello/Dead values do not guarantee an exact end-to-end convergence time; observed results depend on scheduling, event timing, and the rest of the control plane.
