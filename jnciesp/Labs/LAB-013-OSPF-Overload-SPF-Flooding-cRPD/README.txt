LAB-013 — OSPF OVERLOAD BIT, SPF SCHEDULING & LSA FLOODING
Target platform: Juniper cRPD `crpd:23.4R2-S5.6`
Primary source: uploaded Juniper, *Junos OS OSPF User Guide*, Chapter 5, printed pp. 238–251.

ROADMAP NOTE
LAB-012 (metrics, route preference, and ECMP) has been retired as a standalone core lab because it was too basic. Keep its concepts in the toolkit and revisit them when they are useful inside a larger troubleshooting or convergence scenario. The LAB-013 label is retained so existing lab package references do not need renumbering.

PURPOSE
This is a multi-part operational experiment, not a syntax drill:
1. Make R2 advertise itself as overloaded and prove that transit paths avoid it while R2's own stub/loopback remains reachable.
2. Configure OSPF SPF scheduling controls and inspect the active values and their intended effect.
3. Change one interface metric, then prove a new Router-LSA is flooded to another router and route selection changes; restore the metric and verify another update.
4. Optional extension: enable OSPF flood reduction on one P2P link and inspect DoNotAge behavior, if exposed by this cRPD build.

TOPOLOGY / OPERATING MODEL
- Reuse the latest universal Containerlab topology; do not edit or redeploy its YAML for this lab.
- Use R1–R4 only. Their VLAN-tagged P2P links form an Area 0 diamond:
  R1–R2 (VLAN 12 / eth1.12), R1–R3 (VLAN 13 / eth1.13),
  R2–R4 (VLAN 24 / eth1.24), R3–R4 (VLAN 34 / eth1.34).
- Each P2P link uses /30, with `.1` on the lower-numbered router and `.2` on the higher-numbered router.
- Router IDs and loopbacks are 10.1.1.1/32 through 10.1.1.4/32.
- All four adjacencies are point-to-point OSPFv2 in Area 0.
- The cRPD lab exercises routing/control-plane state only. Do not interpret an installed RIB next-hop as proof of end-to-end packet forwarding through a data plane.

PRE-FLIGHT
1. Finish the previous lab and stop any concurrent lab using these VLANs/address ranges.
2. Read `CLEANUP-BEFORE-LAB013.txt` before applying the profile files.
3. Never create, delete, or recreate `br-univ`. It is externally managed.
4. Copy each `configs/rN/lab013-rN-baseline.set` into the matching host bind directory `./configs/rN/`; do not overwrite `base.conf`.
5. Load the matching profile on each router as described in `PROFILE-MAP.txt`, then run `commit check` and `commit`.
6. Establish the baseline before beginning `TASK.txt`.

LAB DESIGN
Tasks 1–4 are the core lab. Task 5 is an optional feature probe for flood reduction. Restore all temporary configuration before moving on. If cRPD rejects a documented feature or fails to produce the expected protocol behavior, save the exact error/output and use the agreed vJunos-router fallback rather than silently dropping the learning objective.
