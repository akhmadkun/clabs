JUNIPER EX GOLDEN TRAINING TOPOLOGY
===================================

Files
-----
clab.yml       Shared physical topology for LAB-001 through LAB-006.
topology.svg   Editable vector topology diagram.
topology.png   PNG preview of the diagram.
configs/       Minimal starter configs so clab.yml has valid startup-config paths.

Nodes
-----
Switches: sw1, sw2, sw3, sw4
Hosts:    Student1, Student2, Teacher1, Teacher2
Switch image: vrnetlab/juniper_vjunos-switch:25.4R1.12
Linux image:  ghcr.io/srl-labs/network-multitool:latest

Physical interface map
----------------------
SW1 ge-0/0/1 <-> SW2 ge-0/0/1
SW1 ge-0/0/2 <-> SW3 ge-0/0/1
SW1 ge-0/0/3 <-> SW4 ge-0/0/1
SW2 ge-0/0/2 <-> SW3 ge-0/0/2  (LACP member 1)
SW2 ge-0/0/3 <-> SW3 ge-0/0/3  (LACP member 2)
SW2 ge-0/0/10 <-> Student1 eth1
SW2 ge-0/0/11 <-> Teacher1 eth1
SW3 ge-0/0/10 <-> Student2 eth1
SW3 ge-0/0/11 <-> Teacher2 eth1

Host IP addressing
------------------
Student1  10.10.10.11/24  VLAN 10 (Students)
Student2  10.10.10.12/24  VLAN 10 (Students)
Teacher1  20.20.20.11/24  VLAN 20 (Teachers)
Teacher2  20.20.20.12/24  VLAN 20 (Teachers)

Important usage notes
--------------------
1. This is the common physical topology only. The configs/ files are minimal
   hostname-only starter configs; they do not configure VLANs, trunking, LACP,
   or RSTP. Copy the configuration files and verification tasks for the lab
   you are currently running into the matching lab directory.
2. The interface mapping in each lab's startup configs, task instructions,
   expected output, and verify.sh must match the map above. Replacing only
   clab.yml in an old lab package is not sufficient because earlier lab
   packages may use different interface mappings and/or different host names.
3. Configure access VLAN 10 on sw2/sw3 ge-0/0/10 and VLAN 20 on
   sw2/sw3 ge-0/0/11 when needed by that lab. The switch-to-switch links
   should be configured as trunks with the VLAN membership required by the
   exercise. The links are physical only; this YAML does not configure them.
4. The two SW2-SW3 physical links are present in every deployment. Configure
   them as members of ae0 in the LACP lab. In other labs, their operation and
   STP role depend on the exercise's startup config.
5. For STP protection exercises, use SW4 as a downstream BPDU source. Do not
   run BPDU Guard and Root Guard on the same SW1-SW4 interface during the same
   test: use separate test phases/configurations so one protection does not
   prevent testing the other.
6. prefix is empty, as requested, so container names are sw1, sw2, etc. Destroy
   the active lab before deploying another lab that reuses those names.

Example
-------
From this directory:
  sudo containerlab deploy -t clab.yml
  sudo containerlab inspect -t clab.yml
  sudo containerlab destroy -t clab.yml --cleanup

This topology has been statically checked for YAML syntax and duplicate physical
interface endpoints. Live Containerlab deployment has not been run here.
