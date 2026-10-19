LAB-011 — OSPF AREA-RANGE SUMMARIZATION & PREFIX SUPPRESSION
Target platform: Juniper cRPD, image `crpd:23.4R2-S5.6`
Source: Junos OS OSPF User Guide (uploaded source), Chapter 5, “Configure OSPF Route Control”, pp. 195–204 (printed page numbers).

PURPOSE
Configure an OSPF area range on R1 (ABR) so three /32 prefixes from Area 1 are summarized into one /24 prefix toward Area 0. Observe that matching specifics are filtered at the area boundary and the summary is advertised in their place.

TOPOLOGY / OPERATING MODEL
- Reuse the user's latest universal Containerlab topology and the pre-existing host bridge `br-univ`.
- Do NOT redeploy a new lab YAML, create/delete/recreate `br-univ`, or change the universal topology for this lab.
- Use R1–R5 only for this exercise. R1 is the ABR between Area 0 and Area 1.
- Link VLAN and Juniper unit follow the router-pair convention: R1–R2 = VLAN 12 / eth1.12; R1–R3 = VLAN 13 / eth1.13; R3–R4 = VLAN 34 / eth1.34; R4–R5 = VLAN 45 / eth1.45.
- All logical links are point-to-point /30. The lower-numbered router uses .1, and the higher-numbered router uses .2.

IMPORTANT PRE-FLIGHT
Only one OSPF lab using these shared VLANs/address spaces should run at a time. Read CLEANUP-BEFORE-LAB011.txt before loading the profile sets. The baseline profiles configure the link addresses, unique router IDs, working OSPFv2 adjacencies, and passive loopbacks. They do not configure the area range—that is the lab task.

PROFILE INSTALLATION
1. Extract this package on the host.
2. Copy each `configs/rN/lab011-rN-baseline.set` file into the corresponding host bind directory `./configs/rN/` in your universal topology. Do not replace `base.conf`.
3. In each router's Junos CLI, enter configuration mode and load that router's profile. See PROFILE-MAP.txt.
4. Run `commit check` then `commit` on each router. Do not load the wrong router's profile.

RECOMMENDED WORKFLOW
1. Complete the cleanup/pre-flight procedure.
2. Load and commit the five baseline profiles.
3. Verify the five-router OSPF baseline using the criteria in TASK.txt.
4. Complete TASK.txt without reading SOLUTION-GUIDE.txt first.
5. Check routes and LSDB before and after enabling `area-range`.

SCOPE
This lab focuses on OSPFv2 intra-area range summarization and the resulting suppression of more-specific routes across the Area 1/Area 0 boundary. It does not configure NSSA external Type 7 aggregation, prefix-export-limit, or policy-based summary filtering; those are distinct controls in the guide and can be covered separately.

VALIDATION
The profiles and documentation were checked for internal consistency when packaged, but have not been deployed in the user's live cRPD environment. Use `commit check` and verify every acceptance criterion on the actual lab. If the cRPD image rejects the feature or behavior, use the agreed fallback approach: recreate/test this lab on vJunos-router rather than silently replacing the learning objective.
