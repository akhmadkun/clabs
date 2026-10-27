LAB-012 — OSPF METRICS, ROUTE PREFERENCE & ECMP
Target platform: Juniper cRPD image `crpd:23.4R2-S5.6`
Source: uploaded Juniper, Junos OS OSPF User Guide, Chapter 5 “Configure OSPF Route Control”, printed pages 208–238.

PURPOSE
Build a clean four-router OSPFv2 diamond and investigate three separate controls:
1. OSPF interface metric / shortest-path selection.
2. Route preference when static and OSPF routes compete for the same prefix.
3. Equal-cost multipath (ECMP) in the routing table.
4. Optional extension: OSPF external route preference using a temporary static route exported from R4.

TOPOLOGY / OPERATING MODEL
- Reuse the latest universal Containerlab topology and the pre-existing host bridge `br-univ`.
- Do not edit/redeploy the universal YAML for this lab. Do not create/delete/recreate `br-univ`.
- Use R1–R4 only. All links are point-to-point in OSPF Area 0.
- Logical link VLAN and Juniper unit are the router-pair number: R1–R2 = VLAN 12 / eth1.12; R1–R3 = VLAN 13 / eth1.13; R2–R4 = VLAN 24 / eth1.24; R3–R4 = VLAN 34 / eth1.34.
- Every P2P link uses /30, with .1 on the lower-numbered router and .2 on the higher-numbered router.
- Loopback router IDs are unique. All router-ID /32 addresses are configured on lo0.0; do not add extra loopback units.

IMPORTANT PRE-FLIGHT
Only one lab using the shared VLAN/IP space should run at a time. Read CLEANUP-BEFORE-LAB012.txt first. Existing labs share the `br-univ` parent bridge and logical VLAN namespace.

PROFILE INSTALLATION
1. Extract this package on the host.
2. Copy `configs/rN/lab012-rN-baseline.set` to the corresponding host bind directory `./configs/rN/` in the universal topology. Do not overwrite `base.conf`.
3. On each listed router, enter configure mode and load only that router's profile. Exact commands are in PROFILE-MAP.txt.
4. Run `commit check`, then `commit` on each router. Verify the baseline before doing the tasks.

RECOMMENDED WORKFLOW
- Complete cleanup and load the baseline on R1–R4.
- Validate Full OSPF adjacencies and the initial equal-cost route to R4's 10.1.1.4/32 loopback from R1.
- Complete TASK.txt in order. The metric experiment and route-preference experiment are separate; restore state between them.
- Complete the external-preference extension only if desired; clean up all temporary static/export configuration afterward.
- Save output evidence before proceeding to LAB-013.

SCOPE / IMPORTANT ECMP DISTINCTION
This lab verifies ECMP route selection and candidate next-hops in the routing table (RIB). It does not claim that cRPD forwards user traffic across both paths in a particular ratio. Juniper's guide distinguishes an ECMP set in the routing table from installation of multiple next hops in the forwarding table using a load-balancing policy. That forwarding-plane exercise is intentionally not required here.

VALIDATION
The configs and expected values were checked for internal consistency when packaged, but have not been deployed on the user's live cRPD image. Use `commit check` and prove each criterion from operational outputs. If a feature/command is unsupported or behavior differs, capture exact errors and use the agreed vJunos-router fallback rather than dropping the learning objective.
