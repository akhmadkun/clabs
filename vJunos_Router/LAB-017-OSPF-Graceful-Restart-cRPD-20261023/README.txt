LAB-017 — OSPF GRACEFUL RESTART: PLANNED RPD RESTART & HELPER MODE

PURPOSE
Prove OSPFv2 Graceful Restart behavior during a controlled routing-process restart of R2, and distinguish configuration/capability from observed helper behavior.

TARGET ENVIRONMENT
- Juniper cRPD on the existing Containerlab universal topology.
- The current working snapshot of jun-ospf.clab.yml uses image xzjt/crpd:25.2R1-S1.4. Verify the actual running release with `show version`; do not assume all local images match this snapshot.
- Use R1, R2, R3, and R4 only.
- R1–R4 make the Area 0 point-to-point diamond over VLANs 12, 13, 24, and 34.
- R2 is the router whose routing protocol daemon will be restarted. R1 and R4 are its direct neighbors and can act as GR helpers.

IMPORTANT DESIGN CHOICES
- There is exactly ONE baseline `.set` file per router under `configs/rN/LAB-017-base.set`. No alternate baseline/incident/target config variants are included.
- The baseline files establish only the addressed interfaces, router ID, and OSPF adjacency. Graceful Restart is intentionally not enabled in the baseline: configuring it on R2 is part of the challenge.
- The baseline set files are reference/additive CLI commands, not replacements for Containerlab `startup-config`. Apply them by pasting the set lines into the Junos configuration prompt if baseline repair is needed. Do not use `load override` on your universal lab config; it could replace unrelated management/system settings.
- This lab does NOT change or redeploy the universal Containerlab YAML and does NOT create/delete/recreate `br-univ`.

CRITICAL PRECONDITION — REMOVE BFD FROM LAB-016
Juniper documentation warns that OSPF Graceful Restart may not work as expected when BFD is configured. Before starting, remove LAB-016 BFD configuration from the relevant OSPF interfaces and verify no BFD sessions remain. See CLEANUP-BEFORE-LAB017.txt. Do not continue with BFD active and then attribute unexpected GR behavior solely to GR.

SAFETY / SCOPE
- This challenge restarts the routing protocol daemon (`rpd`) on R2, not the whole Containerlab node or physical interface.
- Monitor R1 and R4 in separate CLI sessions before triggering the restart on R2.
- cRPD is being used here for routing/control-plane behavior. The lab can validate OSPF LSDB/RIB/helper-state behavior; it does not prove packet forwarding continuity through a hardware/PFE data plane or measure end-to-end traffic loss.
- If GR configuration is rejected, helper mode never engages, or the route behavior contradicts the expectations, save exact command output and classify the feature as unsupported/inconclusive on this build. Do not mark pass just because commit succeeded.

WORKFLOW
1. Read CLEANUP-BEFORE-LAB017.txt.
2. Check CONFIG-MAP.txt and use one LAB-017-base.set file per router only if needed to establish the clean topology.
3. Attempt TASK.txt without using SOLUTION-GUIDE.txt first.
4. Use SOLUTION-GUIDE.txt for command sequences and troubleshooting.
5. Save the required outputs before cleaning up the temporary configuration.

DOCUMENTATION BASIS
- Juniper documents OSPF Graceful Restart, helper-mode defaults, overview verification, trace options, and the `restart routing` action. See REFERENCE.txt.
- Runtime behavior on the user's exact cRPD image is not pre-certified by this package; deployment/verification in the live lab is required.
