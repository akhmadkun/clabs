LAB-003 - OSPF REDISTRIBUTION AND DUAL DEFAULT ROUTES (cRPD)

IMAGE
  xzjt/crpd:25.2R1-S1.4

PURPOSE
  Practice Chapter 4, "Redistribution", from Day One: Advanced OSPF in the
  Enterprise. Focus on Junos route policies, static-to-OSPF redistribution,
  Type-5 external LSAs, and dual default-route origination.

PHYSICAL / LOGICAL DESIGN
  The physical layout is unchanged from LAB-001 and LAB-002. All router parent
  interfaces eth1 connect to the existing host bridge br-univ. The logical
  adjacencies use 802.1Q VLAN subinterfaces:
    VLAN 12 = R1 eth1.12 <-> R2 eth1.12, Area 0 (Backbone)
    VLAN 13 = R1 eth1.13 <-> R3 eth1.13, Area 1
    VLAN 24 = R2 eth1.24 <-> R4 eth1.24, Area 2
  R4 eth2/eth3/eth4 connect to EP16/EP17/EP18 respectively.

FILES
  lab-003.clab.yml         Containerlab topology with external bridge links
  configs/r1.conf          R1 startup config - addressing only
  configs/r2.conf          R2 startup config - addressing only
  configs/r3.conf          R3 startup config - addressing only
  configs/r4.conf          R4 startup config - addressing only
  TASK.txt                 Task-only worksheet
  SOLUTION-GUIDE.txt       Step-by-step solution for junior engineers
  ADDRESS-PLAN.txt         Interface/IP/route plan
  topology.svg             Editable logical topology diagram
  topology.png             Rendered logical topology diagram
  deploy.sh                Checks bridge and avoids concurrent earlier labs
  configure-hosts.sh       Addresses endpoint containers and return routes
  verify.sh                Summarizes neighbors, OSPF routes, and external LSDBs
  destroy.sh               Destroys only the LAB-003 Containerlab deployment
  REFERENCE.txt            Ebook scope, deliberate adaptations, official links

REQUIREMENTS
  - Containerlab and Docker are available to the current user.
  - Existing host Linux bridge br-univ exists and is UP.
  - Image xzjt/crpd:25.2R1-S1.4 is available locally or can be pulled.
  - Image ghcr.io/srl-labs/network-multitool:latest is available locally or can
    be pulled.

IMPORTANT
  Destroy LAB-002 before deployment; do not run labs 001, 002, and 003 together.
  They reuse the same IP addresses, router IDs, VLAN IDs, and physical bridge.
  This lab references but does not create or delete br-univ.
  Startup configs intentionally contain addressing only. Configure router IDs,
  OSPF, static routes, policies, and redistribution manually.
  Discard default routes simulate Type-5 LSA origination only. They do not give
  Internet access and should not be used as a traffic-forwarding solution.
  The book's RIP neighbor R5 is not added. An optional static-route exercise on
  R3 demonstrates similar route-policy/Type-5 mechanics, not RIP redistribution.

START
  1. Read ADDRESS-PLAN.txt.
  2. Run ./deploy.sh
  3. Run ./configure-hosts.sh
  4. Work TASK.txt without looking at the solution.
  5. Use SOLUTION-GUIDE.txt when needed.

RESET
  ./destroy.sh
  ./deploy.sh
  ./configure-hosts.sh

The topology diagram intentionally omits br-univ. It prioritizes the logical
routed links used during Junos OSPF configuration.
