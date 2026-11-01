LAB-019 — OSPF NODE-LINK PROTECTION & NODE-FAILURE RESILIENCE
Package date: 2026-11-01

PURPOSE
  Continue directly from LAB-018. LAB-018 covered OSPF LFA link protection:
  protect a primary R1-R2 link failure while R2 remains alive. LAB-019 raises
  the failure scope to the primary next-hop node itself (R2), using Junos
  OSPF node-link-protection on R1.

PLATFORM PROFILE
  R1: vJunos-router (local-protection router / PLR)
  R2-R4: existing nodes in the current topology (cRPD in the current hybrid profile)
  OSPFv2, Area 0, point-to-point core diamond
  Existing host bridge: br-univ (must remain untouched)

IMPORTANT DESIGN CHOICE
  This is a configuration-and-validation extension for the already-running
  LAB-018 core topology. It intentionally does NOT include a new Containerlab
  YAML or new startup-config files: redeploying the same shared VLAN/IP topology
  would add risk and could disturb the user's existing universal lab. Keep the
  currently deployed node instances and addressing. Only change the R1 OSPF
  protection mode during the exercise; stop/start R2 only for the node-failure
  test.

TOPOLOGY / IDENTIFIERS
  R1 Router ID: 1.1.1.1 (vJunos-router)
  R2 Router ID: 2.2.2.2 (cRPD)
  R3 Router ID: 3.3.3.3 (cRPD)
  R4 Router ID: 4.4.4.4 (cRPD; target loopback 4.4.4.4/32)

  R1 ge-0/0/0.12 <-> R2 eth1.12, VLAN 12 (primary)
  R1 ge-0/0/0.13 <-> R3 eth1.13, VLAN 13 (backup candidate)
  R2 eth1.24 <-> R4 eth1.24, VLAN 24
  R3 eth1.34 <-> R4 eth1.34, VLAN 34

  Observed from the user's LAB-018 outputs:
  - R1 primary next-hop to 4.4.4.4/32: 10.0.12.2 via ge-0/0/0.12
  - R1 backup candidate: 10.0.13.3 via ge-0/0/0.13
  - R1 outgoing OSPF cost on ge-0/0/0.13: 10
  - R3-to-R4 metric in the displayed backup SPF calculation: 1
  - R1's primary route to R4 loopback: OSPF metric 2

  Do not renumber interfaces, IP addresses, router IDs, VLANs, or areas for this
  lab. Confirm the live peer addressing and link state before configuration.

FILES
  TASK.txt                    Outcome-based challenge; attempt this first
  SOLUTION-GUIDE.txt          Guided configuration, verification and cleanup
  ADDRESS-PLAN.txt            Reused topology and observed address references
  CONFIG-CHANGESET-R1.txt     Minimal R1-only configuration delta
  CLEANUP.txt                 Safe rollback / restore checklist
  REFERENCE.txt               Official Juniper, IETF and Containerlab references
  topology.svg                Editable logical topology diagram
  topology.png                PNG preview of the SVG

START
  1. Finish or preserve the LAB-018 evidence. Do not run both protection modes
     simultaneously on the same interface.
  2. Read ADDRESS-PLAN.txt and TASK.txt.
  3. Capture the baseline on R1-R4.
  4. Replace link-protection with node-link-protection on R1 ge-0/0/0.12.
  5. Inspect backup SPF and forwarding-table policy before testing.
  6. Stop only Containerlab node R2 for the node-failure observation.
  7. Start R2 again and verify full recovery.
  8. Use SOLUTION-GUIDE.txt only after attempting TASK.txt.

SAFETY
  - Never stop or destroy the whole topology for this lab.
  - Do not shut down physical parent interfaces or change br-univ.
  - Stop/start R2 only using Containerlab node lifecycle commands and the exact
    topology file/name that owns the currently running R2 node.
  - Do not overwrite an existing forwarding-table export policy. Inspect first.
  - No claim of sub-50-ms convergence or hardware forwarding is allowed from a
    ping summary alone.

VALIDATION NOTE
  The package is a lab design and document bundle. It has not been deployed or
  live-tested in the user's Containerlab environment. Junos syntax, feature
  acceptance, actual backup installation, and forwarding behavior must be
  proven on the user's vJunos-router image/release.
