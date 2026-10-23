LAB-016 — OSPF BFD: DETECTION BUDGET & NEGOTIATED TIMERS
Target: Juniper cRPD, lab baseline `crpd:23.4R2-S5.6`
Scope: OSPFv2 / IPv4 / Area 0 / four-router P2P diamond

PURPOSE
This is an outcome-based network operations challenge, not a CLI recipe. A target for the R1-R3 protected adjacency is BFD minimum interval 300 ms with multiplier 3 (nominal detection target approximately 900 ms in a stable, non-adapting session). The opening profiles are intentionally asymmetric: R1 is configured at 300 ms and R3 at 600 ms. BFD can remain Up with asymmetric timer preferences, but the negotiated operational timers may not meet the intended target. Diagnose from configuration and live session output, correct the configuration, and prove OSPF routing remained healthy.

CONTENTS
- TASK.txt: challenge only; no step-by-step set-command recipe.
- SOLUTION-GUIDE.txt: recommended command sequence, verification and cleanup.
- ADDRESS-PLAN.txt: Router IDs, loopbacks, links, VLAN IDs and IPv4 subnets.
- PROFILE-MAP.txt: which manual .set file is used for each router and scenario.
- CLEANUP-BEFORE-LAB016.txt: safety / cleanup checks before starting.
- VALIDATION-NOTES.txt: assumptions, acceptance boundaries, known caveats.
- REFERENCE.txt: vendor documentation used for syntax and technical framing.
- configs/rN/*.set: manual configuration profiles for the mounted `/lab-configs` directory.
- topology.svg / topology.png: editable diagram and preview.

START HERE
1. Ensure no other lab is using VLANs 12, 13, 24, 34 or loopbacks 10.1.1.1/32 through 10.1.1.4/32.
2. Read CLEANUP-BEFORE-LAB016.txt and PROFILE-MAP.txt.
3. Load the baseline profile on R2/R4; on R1 use the BFD-target profile; on R3 use the incident-start profile. These are full lab profiles in Junos `set` format. They are not loaded by Containerlab automatically.
4. Attempt TASK.txt before opening SOLUTION-GUIDE.txt.
5. Save the `show bfd session detail` evidence before and after the repair.
6. Run the required clean restore when finished.

TOPOLOGY SAFETY
- Reuse the existing universal Containerlab topology; no new or altered YAML is required.
- Parent `eth1` stays on the externally managed `br-univ`; never create, delete, recreate, or shut down it.
- Only logical units `eth1.12`, `eth1.13`, `eth1.24`, and `eth1.34` are used.
- Do not use aggressive BFD intervals below the approved lab value. Do not repeatedly flap the session to force adaptive backoff.

TECHNICAL BOUNDARY
This lab validates control-plane BFD session state and OSPF/RIB behavior. A BFD Detect Time field is a negotiated failure-detection parameter, not a guarantee of exact end-to-end route or application convergence time. cRPD has BFD listed among its supported features in Juniper's deployment documentation, but the exact operational behavior must still be validated on the locally installed image. If the command is rejected or sessions cannot establish, capture the exact error and mark the feature unverified on this build; do not report a pass.
