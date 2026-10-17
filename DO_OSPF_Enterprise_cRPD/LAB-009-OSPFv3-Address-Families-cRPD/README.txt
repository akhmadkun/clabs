LAB-009 - OSPFv3 FUNDAMENTALS AND ADDRESS FAMILIES

REVISION NOTE
This revised package supersedes the earlier build that used arbitrary VLAN IDs 109 and 239. Standard router-pair IDs are now used: R1-R2 = VLAN/unit 12 and R2-R3 = VLAN/unit 23. Addressing profiles, solution commands, cleanup notes, address plan, and topology artwork have been updated together.

Platform target: xzjt/crpd:25.2R1-S1.4 (cRPD-first; feature must be verified on the running image).
Topology source: the user-provided latest jun-ospf.clab.yml. No topology YAML change is required.
Source basis: Juniper Junos OS OSPF User Guide, section "Understanding Multiple Address Families for OSPFv3" and its configuration example, printed pages 41-47.

OBJECTIVE
1. Establish OSPFv3 IPv6-unicast adjacencies and learn remote IPv6 loopbacks.
2. Add the OSPFv3 IPv4-unicast realm on the same logical links and learn IPv4 prefixes through OSPFv3.
3. Verify that the IPv6 and IPv4 address families use separate realms/LSDBs while using the same physical logical links.

TOPOLOGY INTEGRATION
- Keep the latest universal topology YAML as-is. R1-R3 eth1 parent interfaces already attach to the pre-existing br-univ.
- VLAN 12: R1-R2, using eth1.12 on both routers.
- VLAN 23: R2-R3, using eth1.23 on both routers.
- New links use RFC 3849 documentation IPv6 prefixes and documentation IPv4 prefixes. VLAN IDs follow the router-pair convention, so they may reuse IDs from other labs. Do not run LAB-009 concurrently with another lab that uses overlapping VLANs on br-univ.
- Standard rule: point-to-point router links use the concatenated router numbers as VLAN ID and Juniper unit (R1-R2 = VLAN 12 / eth1.12; R2-R3 = VLAN 23 / eth1.23). The `vlan-id` statement sets the actual 802.1Q tag; the unit number alone does not. Multi-access LANs are documented exceptions and must use one explicit shared VLAN.
- Do not recreate, delete, flush, or alter br-univ. Do not edit or redeploy the universal topology just for LAB-009.
- Do not run another OSPF lab using these VLAN IDs/prefixes at the same time.

PLATFORM AND FEATURE CAVEAT
The Juniper guide documents this Junos syntax. This package has not been live-tested against the user's exact cRPD image. Run `commit check` at each stage. If OSPFv3 IPv6 configuration is accepted but `realm ipv4-unicast` is rejected, finish and record the IPv6-unicast portion, save the exact error, and test the IPv4 realm on vJunos-router. Do not claim IPv4 address-family success without seeing the IPv4 routes and realm LSDB.

QUICK START
1. Read CLEANUP-BEFORE-LAB009.txt before loading profiles, especially if coming from LAB-007 or LAB-008.
2. Copy each `configs/rN/lab009-rN-addressing.set` to the existing host-side `configs/rN/` folder that is bind-mounted into `/lab-configs`.
3. Load the matching profile on R1, R2, and R3 using `load set /lab-configs/lab009-rN-addressing.set`; then `commit check` and `commit`.
4. Follow TASK.txt. Do not consult SOLUTION-GUIDE.txt until attempting the tasks.
5. No interface/IP configuration is baked into the topology YAML; all VLAN subinterfaces and addresses are applied via profiles.

FILES
- TASK.txt: task-only worksheet and acceptance criteria.
- SOLUTION-GUIDE.txt: step-by-step configuration and verification.
- ADDRESS-PLAN.txt: IPv4/IPv6 address plan.
- PROFILE-MAP.txt: where the profile files belong and how to load them.
- CLEANUP-BEFORE-LAB009.txt: commands to remove stale LAB-007/LAB-008 OSPF/link configuration safely for this exercise.
- REFERENCE.txt: source notes and operational command list.
- topology.svg / topology.png: editable topology source and raster preview.
- topology-reference/jun-ospf.clab.yml: unchanged reference copy of the supplied topology.
