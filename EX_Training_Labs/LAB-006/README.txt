============================================================
JUNIPER EX SERIES OPERATIONS & TROUBLESHOOTING
LAB-006 — RSTP EDGE / BPDU / ROOT / LOOP PROTECTION
============================================================

PURPOSE
-------
Hands-on exercises for four common spanning-tree protection concepts:

  Cisco concept              Junos EX concept
  ------------------------   ---------------------------------------
  PortFast                   protocols rstp interface <port> edge
  BPDU Guard                 edge + protocols rstp bpdu-block-on-edge
  Root Guard                 protocols rstp interface <port> no-root-port
  Loop Guard                 protocols rstp interface <port>
                             bpdu-timeout-action block

This is a conceptual mapping rather than a claim that the vendors'
implementations and recovery behavior are identical in every detail.

PLATFORM
--------
Switch image: vrnetlab/juniper_vjunos-switch:25.4R1.12
Host image:   ghcr.io/srl-labs/network-multitool:latest

TOPOLOGY
--------
                         SW1 (ROOT, priority 4k)
                        /   |    \       \
                     SW2   SW3    SW4     Host1
                       \___/       (test) 10.10.10.11
                         
Host2 (10.10.10.12) connects to SW3.

Links:
  SW1 ge-0/0/1  <-> SW2 ge-0/0/1
  SW2 ge-0/0/2  <-> SW3 ge-0/0/1
  SW3 ge-0/0/2  <-> SW1 ge-0/0/2
  SW1 ge-0/0/3  <-> SW4 ge-0/0/1  (test port for BPDU Guard/Root Guard)
  Host1 eth1    <-> SW1 ge-0/0/10
  Host2 eth1    <-> SW3 ge-0/0/10

VLAN USERS = VLAN 10. Host1/Host2 are in 10.10.10.0/24.

IMPORTANT SAFETY NOTES
---------------------
1. Run this lab only in an isolated virtual lab; do not connect it to a
   production or external Layer-2 network.
2. Test cases intentionally alter spanning-tree behavior.
3. During the Loop Guard test, stop continuous ping/traffic generation
   before disabling RSTP on SW2 ge-0/0/2. If the protection is absent or
   behaves differently on the emulated platform, the triangle can form a
   Layer-2 loop. Restore RSTP promptly after observation.
4. Do not configure no-root-port and bpdu-timeout-action block on the
   same interface. Juniper documents root protection and loop protection
   as mutually exclusive on a given interface.

FILES
-----
TASK-ONLY.txt            Participant instructions without solutions.
SOLUTION-GUIDE.txt       Full lab walkthrough and recovery commands.
clab.yml                 Containerlab topology.
configs/*.conf           Clean starting configurations.
configs/solution/*.conf  Example steady-state configuration with guards.
scripts/verify.sh        Host-to-host ping helper plus CLI checklist.

DEPLOY
------
From this directory:
  containerlab deploy -t clab.yml

Wait until all vJunos switches finish booting, then run:
  ./scripts/verify.sh

CLEAN UP
--------
  containerlab destroy -t clab.yml

References (official Juniper documentation):
- Edge: https://www.juniper.net/documentation/us/en/software/junos/cli-reference/topics/ref/statement/edge-edit-protocols-stp.html
- BPDU protection: https://www.juniper.net/documentation/us/en/software/junos/stp-l2/topics/topic-map/spanning-tree-bpdu-protection.html
- Root protection: https://www.juniper.net/documentation/us/en/software/junos/cli-reference/topics/ref/statement/no-root-port-edit-protocols-stp.html
- Loop protection: https://www.juniper.net/documentation/us/en/software/junos/stp-l2/topics/topic-map/spanning-tree-loop-protection.html
