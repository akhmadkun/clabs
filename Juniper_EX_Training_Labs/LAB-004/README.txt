============================================================
JUNIPER EX SERIES OPERATIONS & TROUBLESHOOTING
LAB-004 — LAYER-2 TROUBLESHOOTING CHALLENGE
============================================================

PURPOSE
-------
This is a practical multi-fault troubleshooting lab for junior
network engineers.

The topology is intentionally based on the LAB-003 RSTP triangle,
but the startup configuration contains several Layer-2 faults.
Your job is to diagnose the incident methodically and restore
end-to-end connectivity.

LAB OBJECTIVES
--------------
1. Separate host, physical, VLAN, STP, and MAC-learning symptoms.
2. Build a troubleshooting hypothesis from command output.
3. Identify configuration faults without rebuilding the topology.
4. Restore service with the smallest safe configuration change.
5. Prove the fix end-to-end.
6. Practice a repeatable workflow:
   Problem -> Observation -> Hypothesis -> Verification -> Root Cause
   -> Fix -> End-to-End Verification

IMAGE
-----
vrnetlab/juniper_vjunos-switch:25.4R1.12

HOST IMAGE
----------
ghcr.io/srl-labs/network-multitool:latest

TOPOLOGY
--------

                    SW1
                EX-TRAIN-SW1
                 /       \
                /         \
              SW2---------SW3
        EX-TRAIN-SW2   EX-TRAIN-SW3
                           |
                         Host2

Host1 is connected to SW1.
Host2 is connected to SW3.
The three switches form an RSTP triangle.

INTERFACES
----------
SW1 ge-0/0/1 <-> SW2 ge-0/0/1
SW2 ge-0/0/2 <-> SW3 ge-0/0/1
SW3 ge-0/0/2 <-> SW1 ge-0/0/2
Host1 eth1     <-> SW1 ge-0/0/10
Host2 eth1     <-> SW3 ge-0/0/10

ADDRESSING
----------
Host1 = 10.10.10.11/24
Host2 = 10.10.10.12/24
VLAN USERS = VLAN 10

INTENDED DESIGN
---------------
SW1 should be the RSTP root bridge.
Host1 and Host2 should be in VLAN USERS (VLAN 10).
The inter-switch links should carry VLAN USERS.
Host1 must be able to ping Host2.

FILES
-----
TASK-ONLY.txt
    Participant version. No fault list or solution commands.

SOLUTION-GUIDE.txt
    Full walkthrough, fault explanation, commands, expected results,
    verification, rollback/recovery, and junior-engineer tips.

clab.yml
    Containerlab topology.

configs/*.conf
    Intentionally broken startup configurations.

configs/solution/*.conf
    Known-good configurations for recovery/reference.

scripts/verify.sh
    End-to-end verification helper.

DEPLOY
------
From this directory:

  containerlab deploy -t clab.yml

Wait for all three vJunos switches to finish booting.

VERIFY CONTAINERS
-----------------

  docker ps --format 'table {{.Names}}\t{{.Status}}'

CLEANUP
-------

  containerlab destroy -t clab.yml

IMPORTANT
---------
The lab is deliberately broken at startup. Do not use the solution
configuration files during the challenge unless you are in recovery
mode.
