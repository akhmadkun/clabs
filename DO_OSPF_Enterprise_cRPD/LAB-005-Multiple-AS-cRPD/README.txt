LAB-005 - MULTIPLE AUTONOMOUS SYSTEMS (cRPD)

SOURCE
  Day One: Advanced OSPF in the Enterprise, Chapter 6, "Multiple Autonomous Systems".

IMAGE
  cRPD routers: xzjt/crpd:25.2R1-S1.4
  Linux endpoints: ghcr.io/srl-labs/network-multitool:latest

OBJECTIVE
  Connect the existing multi-area OSPF network (AS 65001) to a separate OSPF
  network (AS 65002) using eBGP, then selectively redistribute OSPF routes to
  BGP and BGP routes to OSPF. Verify the route tables and Type-4/Type-5 LSAs.

PHYSICAL / LOGICAL DESIGN
  All router eth1 parent interfaces attach to the pre-existing host bridge
  br-univ. The lab does not create, configure, or delete br-univ.
  Logical router-to-router links use 802.1Q VLAN subinterfaces.

  AS 65001 - inherited OSPF design from LAB-004:
    VLAN 12: R1 eth1.12 <-> R2 eth1.12, Area 0 / inet.0
    VLAN 13: R1 eth1.13 <-> R3 eth1.13, Area 1 / inet.0
    VLAN 24: R2 eth1.24 <-> R4 eth1.24, Area 2 / inet.0
    VLAN 16: R1 domain2 eth1.16 <-> R6 eth1.16, Area 0 / domain2 instance
    VLAN 67: R6 eth1.67 <-> R7 eth1.67, Area 1 / Domain 2

  eBGP boundary:
    VLAN 28: R2 eth1.28 (10.0.28.1/30) <-> R8 eth1.28 (10.0.28.2/30)
    R2 belongs to AS 65001; R8 belongs to AS 65002.

  AS 65002 - independent OSPF:
    VLAN 89: R8 eth1.89 (10.0.89.1/30) <-> R9 eth1.89 (10.0.89.2/30)
    R8 loopback is in Area 0; R8-R9 link and R9 LANs are in Area 1.

STARTUP-CONFIG RULE
  All router startup configs contain addressing and VLAN IDs only. They do not
  include router IDs, AS numbers, OSPF, BGP, routing-instances, static routes,
  RIB groups, or route policies. Configure those features during the exercise.

FILES
  lab-005.clab.yml       Containerlab topology
  configs/r1.conf...r9.conf
                         Addressing-only configs (R5 is not used in this adaptation)
  TASK.txt               Task-only worksheet
  SOLUTION-GUIDE.txt     Step-by-step guide for junior engineers
  ADDRESS-PLAN.txt       IP addressing, VLAN mapping, areas and AS numbers
  REFERENCE.txt          Ebook mapping, adaptations and official documentation
  topology.svg/.png      Logical network diagram; bridge omitted intentionally
  deploy.sh              Checks bridge and older lab containers, then deploys
  configure-hosts.sh     Configures EP16/17/18 and EP91/92
  verify.sh              Shows OSPF, routing-instance, BGP and route information
  destroy.sh             Destroys LAB-005 only and leaves br-univ intact

REQUIREMENTS
  - Containerlab and Docker available to the current user.
  - The external host bridge br-univ exists and is UP.
  - Image xzjt/crpd:25.2R1-S1.4 is available locally or pullable.
  - Image ghcr.io/srl-labs/network-multitool:latest is available/pullable.

IMPORTANT
  Destroy any active LAB-001 through LAB-004 deployment first. These labs reuse
  the same router names/IDs, endpoint networks and external bridge. Never run
  them in parallel. Keep the physical bridge br-univ intact.

START
  1. Read ADDRESS-PLAN.txt and TASK.txt.
  2. Run ./deploy.sh
  3. Run ./configure-hosts.sh
  4. Complete TASK.txt without the solution guide first.
  5. Use SOLUTION-GUIDE.txt when you need a guided configuration sequence.

RESET
  ./destroy.sh
  ./deploy.sh
  ./configure-hosts.sh
