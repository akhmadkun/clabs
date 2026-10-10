LAB-002 - STUB AREAS, TOTALLY STUBBY, AND NSSA (cRPD)

IMAGE
  xzjt/crpd:25.2R1-S1.4

PURPOSE
  Practice Chapter 3, "Stubbiness", from Day One: Advanced OSPF in the Enterprise.
  The lab keeps LAB-001's physical topology and uses 802.1Q logical links:
    VLAN 12 = Area 0; VLAN 13 = Area 1; VLAN 24 = Area 2.
  Area 1 will be tested as normal, stub, totally stubby, NSSA, and optionally
  NSSA with no-summaries.

FILES
  lab-002.clab.yml       Containerlab topology and physical bridge attachments
  configs/r1.conf        R1 startup config - addressing only
  configs/r2.conf        R2 startup config - addressing only
  configs/r3.conf        R3 startup config - addressing only
  configs/r4.conf        R4 startup config - addressing only
  TASK.txt               Task-only worksheet
  SOLUTION-GUIDE.txt     Step-by-step instructions for junior engineers
  ADDRESS-PLAN.txt       Interface/IP and route plan
  topology.svg           Editable vector logical topology
  topology.png           Rendered logical topology reference
  deploy.sh              Guarded deployment; does not create/delete br-univ
  configure-hosts.sh     Address endpoint containers and add return routes
  verify.sh              Show neighbors, OSPF routes, and LSDBs
  destroy.sh             Destroy only the LAB-002 topology
  REFERENCE.txt          Ebook adaptation notes and official documentation URLs

REQUIREMENTS
  - Containerlab and Docker are installed and available to the current user.
  - The existing Linux bridge br-univ is present and UP on the host.
  - The image xzjt/crpd:25.2R1-S1.4 is available locally or pullable.
  - The image ghcr.io/srl-labs/network-multitool:latest is available locally or pullable.

IMPORTANT
  LAB-001 and LAB-002 reuse the same router IDs, VLAN IDs, and IP prefixes.
  Do not run both at once. Destroy LAB-001 before deployment of LAB-002.
  The lab does not create, configure, or delete the external br-univ bridge.
  All four cRPD startup configs contain addressing only. Configure router IDs,
  OSPF, area types, static routes, and export policy manually during the lab.

START
  1. Read ADDRESS-PLAN.txt.
  2. Run ./deploy.sh
  3. Run ./configure-hosts.sh
  4. Work through TASK.txt first.
  5. Consult SOLUTION-GUIDE.txt only when needed.

RESET
  ./destroy.sh
  ./deploy.sh
  ./configure-hosts.sh

The topology image omits the physical bridge intentionally. It shows the logical
connections needed when configuring OSPF on the routers.
