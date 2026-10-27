LAB-018 — OSPF LOOP-FREE ALTERNATE (LFA): LINK PROTECTION
Package: LAB-018-OSPF-LFA-Link-Protection-cRPD-20261025

PURPOSE
Prove the difference between a merely reachable alternate path and an OSPF LFA backup candidate. Configure link protection for R1's primary R1-R2 interface and inspect backup SPF/coverage diagnostics on cRPD.

PLATFORM
- First attempt: existing cRPD image crpd:23.4R2-S5.6.
- Four routers R1-R4, OSPFv2 Area 0, P2P diamond, VLANs 12/13/24/34.
- Use the existing universal Containerlab / br-univ environment. This package does not create, delete, or re-create br-univ and does not include a second topology YAML that might conflict with the user's running lab.
- There is exactly one startup configuration file per router: configs/r1/base.conf through configs/r4/base.conf.

HOW THIS TOPOLOGY IS PRECONDITIONED
R1's outgoing OSPF metric on eth1.13 is intentionally 10. Other link metrics use the default 1. This makes R1 choose R2 as the unique primary next hop toward R4 loopback (metric 2), while R3 remains a candidate loop-free alternate. The asymmetric interface metric is intentional: OSPF interface cost is advertised by each router for its own outgoing link; do not set R3's eth1.13 cost to 10 for the core task.

IMPORTANT LIMITATION
LFA in Juniper routers precomputes backup paths for local repair in the forwarding plane. cRPD is being used first here to test whether its installed build accepts the configuration and exposes backup-SPF/coverage information. This package does NOT assume cRPD implements hardware/PFE fast reroute. Do not claim sub-50-ms failover or data-plane continuity from control-plane output. If link-protection or the backup operational commands are unsupported, capture the exact output and then use the vJunos-router fallback workflow rather than marking LFA as passed.

WORKFLOW
1. Read CLEANUP-BEFORE-LAB018.txt and CONFIG-MAP.txt.
2. Apply one base.conf per router using the user's existing, proven configuration-loading mechanism. Do not overwrite the universal baseline without making a backup.
3. Perform TASK.txt without following the command-by-command solution.
4. Use SOLUTION-GUIDE.txt only when needed.
5. Restore the lab baseline and prove all OSPF adjacencies and routes are healthy.

STATUS
Package checks (file count, configuration uniqueness, SVG parsing, PNG render, ZIP integrity) passed. The commands and features have NOT been live-tested on the user's cRPD build.
