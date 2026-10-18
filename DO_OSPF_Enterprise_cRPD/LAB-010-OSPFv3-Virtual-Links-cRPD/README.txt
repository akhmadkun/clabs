LAB-010 - OSPFv3 VIRTUAL LINKS
Platform target: xzjt/crpd:25.2R1-S1.4; cRPD-first, feature compatibility must be verified on the running image.
Source: Juniper Networks, Junos OS OSPF User Guide (published 2026-06-18), Chapter 4, “Example: Configuring OSPFv3 Virtual Links”, printed pages 159-174.

OBJECTIVE
Build the physical OSPFv3 IPv6-unicast areas first, observe the effect of a disconnected Area 0, then configure two OSPFv3 virtual links through normal transit Area 1:
  1. R3 <-> R4 connects the two physically disconnected Area 0 segments.
  2. R4 <-> R6 extends Area 0 reachability to the Area 2 / R10 side.

UNIVERSAL TOPOLOGY INTEGRATION
Use the user's current jun-ospf.clab.yml as-is. The topology already binds eth1 on R1, R2, R3, R4, R6 and R10 to the existing external br-univ. Do not create, delete, flush, or recreate br-univ. Profiles are copied to the matching host folders configs/rN/ and loaded manually through /lab-configs/.
No topology YAML modification is required. This package intentionally contains only address/interface profiles; the learner configures OSPFv3 and virtual links manually.

ROUTER MAPPING TO THE JUNIPER GUIDE
  Guide Device 0 -> R1
  Guide Device 1 -> R2
  Guide Device 2 -> R3
  Guide Device 3 -> R4
  Guide Device 4 -> R6
  Guide Device 5 -> R10

IMPORTANT
- This is OSPFv3 for IPv6 unicast only. Do not enable the LAB-009 `realm ipv4-unicast` configuration in this exercise. Juniper's guide calls out virtual links as an exception to configuration support for additional OSPFv3 realms.
- Transit Area 1 must remain a normal, non-stub area with full routing information.
- The two virtual links are configured under `protocols ospf3 area 0.0.0.0` and must be configured at both endpoints.
- Ensure router IDs are unique. R1, R2, R3, R4, R6 and R10 use 10.1.1.1, .2, .3, .4, .6 and .10 respectively.
- Router loopback IPv4 addresses used for Router IDs are inherited from base.conf; profiles add IPv6 loopbacks 2001:db8:ffff::N/128 for OSPFv3 route verification.
- Logical VLAN and Juniper unit number match the router pair: R1-R4=14, R2-R3=23, R3-R4=34, R3-R6=36, R4-R6=46, R6-R10=610.
- Do not run another OSPF lab using any of these VLANs/IP prefixes at the same time.

PROFILE WORKFLOW
1. Follow CLEANUP-BEFORE-LAB010.txt before loading profiles.
2. Copy each matching `configs/rN/lab010-rN-addressing.set` into the host folder `configs/rN/` that is bind-mounted to `/lab-configs` by jun-ospf.clab.yml.
3. On each router, run:
     configure
     load set /lab-configs/lab010-rN-addressing.set
     commit check
     commit
   Replace N with the matching router name/number. These are addressing profiles, not startup configs.
4. Configure OSPFv3 manually following TASK.txt. Do not load SOLUTION-GUIDE.txt if treating the lab as an exam.

FEATURE COMPATIBILITY
This package was not deployed against the user's running cRPD image while authored. Confirm each stage with `commit check`. If OSPFv3 `virtual-link` is rejected or fails to establish adjacency, preserve the exact error/output; do not claim success from the accepted configuration alone. Use vJunos-router for a compatibility comparison if needed.
