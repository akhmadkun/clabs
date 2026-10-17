LAB-008 - OSPF MULTI-AREA ADJACENCY

Platform target: xzjt/crpd:25.2R1-S1.4 (cRPD-first, feature must be verified on the running image)
Topology: use the supplied latest universal topology file jun-ospf.clab.yml as-is.

OBJECTIVE
Configure one logical interface between R1 and R2 as a primary OSPF adjacency in Area 0 and a secondary OSPF adjacency in Area 1. Compare the Area 1 route before and after adding the multi-area adjacency.

TOPOLOGY INTEGRATION
- No changes to jun-ospf.clab.yml are required. R1-R4 already attach eth1 to the existing br-univ node/host bridge.
- Use VLAN 12 for R1-R2, VLAN 13 for R1-R3, VLAN 34 for R3-R4, and VLAN 24 for R4-R2.
- The `eth1.<unit>` number matches the VLAN ID in this lab: eth1.12 = VLAN 12, etc.
- Keep br-univ intact. Do not create, delete, flush, or recreate it for this lab.
- Only R1 and R2 should have VLAN 12 configured. This isolates the secondary Area 1 adjacency to those two routers; Juniper documents this requirement for secondary adjacencies over a LAN.
- Do not run other OSPF labs that reuse these VLAN IDs/IP prefixes at the same time.

PROFILE WORKFLOW
The topology bind-mounts each host folder `./configs/rN` into `/lab-configs` on that router. Copy this package's `configs/r1/lab008-r1-baseline.set` etc. into the matching host folder. The files are not applied automatically.

On each router, load the baseline profile from Junos configuration mode:
  configure
  load set /lab-configs/lab008-r1-baseline.set
  commit check
  commit

Substitute the matching router filename on R2-R4. The base.conf loopback address is assumed to remain `10.1.1.N/32`; the baseline profile sets the OSPF router ID explicitly but does not overwrite the loopback address.

IMPORTANT IF COMING DIRECTLY FROM LAB-007
Do not merge LAB-008 into a still-active LAB-007 OSPF configuration. Remove the prior LAB-007 OSPF stanza and the old `eth1.1234` unit (VLAN 100) on R1-R4, and remove prior LAB-008 test units if reloading the profile. Preserve `system`, authentication, SSH, and the existing base `lo0.0` address. Exact clean-up commands are in CLEANUP-BEFORE-LAB008.txt.

FEATURE VALIDATION
Juniper documents the `secondary` OSPF interface option for multi-area adjacency. This package has not been live-tested against your local cRPD image. First use `commit check`; if cRPD rejects `secondary`, capture the exact error and switch this exercise to vJunos-router rather than pretending the feature worked. If the commit succeeds, confirm the secondary interface and second adjacency using the verification commands in TASK.txt / SOLUTION-GUIDE.txt.
