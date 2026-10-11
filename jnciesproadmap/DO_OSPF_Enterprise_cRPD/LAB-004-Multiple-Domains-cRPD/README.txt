LAB-004 - MULTIPLE HOMOGENEOUS OSPF DOMAINS (cRPD)

IMAGE
  xzjt/crpd:25.2R1-S1.4
  Endpoints: ghcr.io/srl-labs/network-multitool:latest

PURPOSE
  Practice Chapter 5 of Day One: Advanced OSPF in the Enterprise. Create a
  second OSPF instance on R1, inspect the separated route tables, then exchange
  routes with RIB groups and external OSPF export policies.

PHYSICAL / LOGICAL DESIGN
  All six cRPD routers (R1, R2, R3, R4, R6, R7) connect their eth1 parent to the
  pre-existing host bridge br-univ. Containerlab does not create/delete br-univ.
  VLAN 12: Domain 1 Area 0, R1-R2
  VLAN 13: Domain 1 Area 1, R1-R3
  VLAN 24: Domain 1 Area 2, R2-R4
  VLAN 56: Domain 2 Area 0, R1's domain2 instance-R6
  VLAN 67: Domain 2 Area 1, R6-R7

FILES
  lab-004.clab.yml    topology
  configs/*.conf      addressing-only cRPD startup configs
  TASK.txt            task-only worksheet
  SOLUTION-GUIDE.txt  step-by-step solution for junior engineers
  ADDRESS-PLAN.txt    addressing and VLAN map
  REFERENCE.txt       ebook mapping, adaptations and official document links
  topology.png/.svg   logical topology visual
  deploy.sh           guarded deployment; never creates/removes br-univ
  configure-hosts.sh  configures EP16-EP18 Linux endpoints
  verify.sh           show neighbor tables, RIBs and OSPF database summaries
  destroy.sh          destroys this lab only; leaves br-univ intact

REQUIREMENTS
  - Containerlab and Docker are installed and available to the user.
  - Host bridge br-univ exists and is UP.
  - cRPD image xzjt/crpd:25.2R1-S1.4 is available.
  - The endpoint image ghcr.io/srl-labs/network-multitool:latest is available/pullable.

IMPORTANT
  Do not run LAB-001, LAB-002, LAB-003 and LAB-004 simultaneously. The exercises
  reuse parts of the same IP and VLAN plan over the shared physical bridge.
  All OSPF configuration is performed manually. Startup configs only provide
  interface addresses and VLAN IDs.

START
  1. Read ADDRESS-PLAN.txt and TASK.txt.
  2. Run ./deploy.sh
  3. Run ./configure-hosts.sh
  4. Work through TASK.txt.
  5. Use SOLUTION-GUIDE.txt only as needed.

RESET
  ./destroy.sh
