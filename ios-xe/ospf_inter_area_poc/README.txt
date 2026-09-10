OSPF Inter-Area ABR Selection PoC
=================================

Goal
----
Demonstrate the distinction between:
1. the advertising ABR selected by R1 for an inter-area route, and
2. the immediate next hop used by R1 to reach that ABR.

Topology
--------
Area 0:
  R1--5--R2
  |      |\
  5      5 5
  |      |  \
  R3--3--R4

Area 1:
  R3--20--R5--5--R6
  |               |
  +------30-------+
                  \
                  R4--5--R6

Important costs
---------------
R3 -> R6 inside Area 1:
  R3 -> R6 = 30
  R3 -> R5 -> R6 = 20 + 5 = 25

R4 -> R6 inside Area 1:
  R4 -> R6 = 5

From R1 to advertising ABRs in Area 0:
  R1 -> R3 = 5
  R1 -> R4 = 5 + 3 = 8 (via R3)

Therefore R1's inter-area cost to 6.6.6.6 is:
  via R3 = 5 + 25 = 30
  via R4 = 8 + 5 = 13

R4 is the selected advertising ABR, but R3 is R1's immediate next hop toward R4.
The resulting forwarding path is:
  R1 -> R3 -> R4 -> R6

Containerlab interface mapping (official docs)
-----------------------------------------------
For cisco_iol:
  eth0 = management -> Ethernet0/0
  eth1 = first data interface -> Ethernet0/1
  eth2 = second data interface -> Ethernet0/2
  eth3 = third data interface -> Ethernet0/3
  eth4 = fourth data interface -> Ethernet1/0
  eth5 = fifth data interface -> Ethernet1/1

This topology uses those IOL interface names directly.

Deploy
------
containerlab deploy -t topology.clab.yml

Verify
------
./verify.sh

Useful checks
-------------
R1:
  show ip route 6.6.6.6
  show ip ospf database summary 6.6.6.6

R3:
  show ip route ospf 6.6.6.6

R4:
  show ip route ospf 6.6.6.6

Note
----
The startup files use the .partial form so containerlab can retain its default IOL management/SSH setup while adding the lab-specific configuration.
