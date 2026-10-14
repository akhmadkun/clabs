============================================================
JUNIPER EX SERIES OPERATIONS & TROUBLESHOOTING
LAB-005 — EX SERIES DAY-2 OPERATIONS
============================================================

PURPOSE
-------
This lab practices routine operations on a Juniper EX-style switching
platform running Junos in vJunos-switch. The objective is to build a
repeatable operational workflow, not to solve a pre-planted outage.

LAB OBJECTIVES
--------------
1. Collect a baseline health and operational snapshot.
2. Verify interface state, VLAN membership, MAC learning, and host reachability.
3. Save a committed configuration to a local file.
4. Make a small change and inspect the candidate diff before commit.
5. Use commit comments to leave an auditable change record.
6. Understand rollback 0 versus rollback 1.
7. Demonstrate commit confirmed with automatic rollback.
8. Restore a known-good snapshot with load merge.
9. Finish with end-to-end and configuration verification.

PLATFORM
--------
Switch image:
  vrnetlab/juniper_vjunos-switch:25.4R1.12

Host image:
  ghcr.io/srl-labs/network-multitool:latest

Virtual Chassis is deliberately out of scope.

TOPOLOGY
--------
                  EX-TRAIN-SW1
                +----------------+
Host1 ----------| ge-0/0/10       |
10.10.10.11/24  | VLAN USERS 10   |
Host2 ----------| ge-0/0/11       |
10.10.10.12/24  +----------------+

Both hosts are in the same VLAN and subnet. They should be able to ping
one another without a router or default gateway.

FILES
-----
TASK-ONLY.txt
    Participant tasks without the worked solution.

SOLUTION-GUIDE.txt
    Self-contained walkthrough with commands, expected observations,
    explanations, recovery notes, and operational tips.

clab.yml
    Containerlab topology. Node names are direct because prefix is empty.

configs/sw1.conf
    Hierarchical Junos startup configuration.

configs/solution/sw1.conf
    Reference known-good switch configuration.

scripts/verify.sh
    Host-to-host connectivity test plus a manual Junos command checklist.

DEPLOY
------
Run from this directory:

  containerlab deploy -t clab.yml

Confirm that the containers are running:

  docker ps --format 'table {{.Names}}\t{{.Status}}'

The vJunos switch needs time to boot. Wait until the Junos CLI is ready
before running switch commands.

VERIFY
------
  chmod +x scripts/verify.sh
  ./scripts/verify.sh

CLEANUP
-------
  containerlab destroy -t clab.yml

IMPORTANT
---------
- The starting configuration is intentionally healthy.
- Complete the exercises in order so rollback history is predictable.
- The commit-confirmed exercise intentionally disables only Host1's
  access port for about one minute. Do NOT confirm that temporary commit.
- Do not use load override for the file-recovery exercise; it replaces
  the candidate configuration rather than merging selected values.
- This is a virtual platform. Hardware inventory and alarm output may
  differ from physical EX hardware; record unexpected output rather than
  assuming every virtual-platform warning is a production fault.
