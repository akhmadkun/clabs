LAB-006 - OSPF VIRTUAL LINKS (cRPD)

SOURCE
  Day One: Advanced OSPF in the Enterprise, Chapter 7, "Virtual Links".

OBJECTIVE
  Demonstrate that Area 3 prefixes do not reach the backbone before a virtual
  link, create a virtual link between R2 and R10 through transit Area 2, then
  verify the virtual adjacency and Area 3 route propagation.

IMAGE
  cRPD routers: xzjt/crpd:25.2R1-S1.4
  Linux endpoints: ghcr.io/srl-labs/network-multitool:latest

PHYSICAL / LOGICAL DESIGN
  All router eth1 parent interfaces attach to the pre-existing external bridge
  br-univ. The lab does not create, configure or delete that bridge.
  VLAN 12: R1-R2 Area 0 (broadcast)
  VLAN 13: R1-R3 Area 1 (point-to-point)
  VLAN 24: R2-R4 Area 2 transit (point-to-point)
  VLAN 410: R4-R10 Area 2 transit (point-to-point)
  Area 3 host prefixes 192.168.76.0/24 and 192.168.77.0/24 are behind R10.

FILES
  lab-006.clab.yml       Containerlab topology
  configs/*.conf         Five cRPD startup configs, addressing-only
  TASK.txt               Task-only worksheet with per-task acceptance criteria
  SOLUTION-GUIDE.txt     Step-by-step guide for junior engineers
  ADDRESS-PLAN.txt       Interface/IP/VLAN and area plan
  REFERENCE.txt          Ebook mapping and official documentation URLs
  topology.svg/.png      Logical topology diagram; bridge omitted intentionally
  deploy.sh              Checks external bridge and prevents concurrent labs
  configure-hosts.sh     Assigns endpoint addresses and default gateways
  verify.sh              Displays neighbor, route, interface, and LSDB details
  destroy.sh             Destroys this lab only and leaves br-univ intact

START
  1. Read ADDRESS-PLAN.txt and TASK.txt.
  2. Run ./deploy.sh
  3. Run ./configure-hosts.sh
  4. Work through TASK.txt before opening SOLUTION-GUIDE.txt.

IMPORTANT
  Do not run multiple labs from this series simultaneously because they share
  the same bridge and reuse overlapping IP/VLAN plans. Destroy the previous lab
  first. Do not delete br-univ.

VALIDATION
  Syntax and package structure are checked locally. Live cRPD boot, `commit check`,
  virtual-link convergence and end-to-end forwarding must be verified in the
  user's Containerlab environment; these have not been executed in the build environment.
