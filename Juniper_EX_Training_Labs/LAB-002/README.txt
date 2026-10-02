============================================================
LAB-002
JUNIPER EX SERIES OPERATIONS & TROUBLESHOOTING
LACP / AGGREGATED ETHERNET (AE)
============================================================

Purpose
-------
Build and troubleshoot a Layer-2 LACP bundle between two Juniper
vJunos-switch devices.

This lab is designed for junior engineers. The focus is on the
operational workflow, not only on memorizing configuration syntax.

Image
-----
vrnetlab/juniper_vjunos-switch:25.4R1.12

Topology
--------

             SW1                         SW2
        +------------+              +------------+
        |            |              |            |
 HOST1--| ge-0/0/0   |              | ge-0/0/0   |--HOST2
        |            |              |            |
        | ge-0/0/1   |==============| ge-0/0/1   |
        | ge-0/0/2   |==============| ge-0/0/2   |
        +------------+              +------------+
                    <--- LACP / ae0 --->

VLAN 10: USERS
HOST1: 10.10.10.11/24
HOST2: 10.10.10.12/24

Notes
-----
1. The startup configurations intentionally prepare the endpoint
   VLAN/access ports and the physical inter-switch interfaces.
2. The AE/LACP configuration is intentionally left for the trainee.
3. The startup configuration files use native hierarchical Junos
   syntax because they are loaded by the vJunos-switch startup
   configuration mechanism.
4. "set ..." syntax is still used during the hands-on exercises.

Useful commands
---------------
show interfaces terse
show configuration interfaces
show configuration interfaces ge-0/0/1
show configuration interfaces ge-0/0/2
show configuration interfaces ae0
show lacp interfaces
show interfaces ae0 extensive
show ethernet-switching interfaces
show ethernet-switching table
show vlans
show log messages

Reference
---------
Containerlab vJunos-switch documentation:
https://containerlab.dev/manual/kinds/vr-vjunosswitch/

Juniper LACP / Aggregated Ethernet documentation:
https://www.juniper.net/documentation/us/en/software/junos/cli-reference/
