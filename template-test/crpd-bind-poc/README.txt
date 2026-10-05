CRPD BIND DIRECTORY + LOAD OVERRIDE POC
=======================================

Purpose
-------
Prove that one host directory containing multiple cRPD configuration files can
be bind-mounted into a running Containerlab `juniper_crpd` node and each file
can be loaded with Junos `load override` without redeploying the topology.

Files
-----
crpd-bind-poc/
├── topology.clab.yml
├── load-crpd.sh
├── verify.sh
└── configs/
    ├── lab1.conf
    ├── lab2.conf
    └── lab3.conf

Containerlab setup
------------------
Kind: juniper_crpd
Image: xzjt/crpd:25.2R1-S1.4
Management: 172.31.90.11/24

The bind is:
  ./configs  ->  /lab-configs:ro

The PoC intentionally does NOT bind over `/config` because containerlab uses
`/config` as the cRPD node's persistent configuration directory.

Containerlab documents for juniper_crpd:
- `eth0` = management interface
- `eth1` = first data interface
- cRPD has a dedicated `/config` directory
- a user `startup-config` is copied to the node's `/config/juniper.conf`

Run
---
1. Deploy once:
   sudo containerlab deploy -t topology.clab.yml

2. Verify the bind:
   docker exec -it clab-crpd-bind-poc-crpd1 ls -la /lab-configs

3. Load lab1:
   ./load-crpd.sh lab1.conf

4. Load lab2 WITHOUT redeploy:
   ./load-crpd.sh lab2.conf

5. Load lab3 WITHOUT redeploy:
   ./load-crpd.sh lab3.conf

6. Or run the complete PoC:
   ./verify.sh

Manual Junos method
-------------------
docker exec -it clab-crpd-bind-poc-crpd1 cli

configure
load override /lab-configs/lab1.conf
commit

Then:
configure
load override /lab-configs/lab2.conf
commit

What changes between the three files
-------------------------------------
lab1: hostname CRPD-LAB1, router-id 1.1.1.1, lo0 1.1.1.1/32
lab2: hostname CRPD-LAB2, router-id 2.2.2.2, lo0 2.2.2.2/32
lab3: hostname CRPD-LAB3, router-id 3.3.3.3, lo0 3.3.3.3/32

Important
---------
Junos `load override` replaces the candidate configuration with the selected
file. Therefore a scenario file should contain every configuration element
that must remain after the replacement.

This PoC is intentionally one cRPD node and three complete small configs so the
bind mount and no-redeploy workflow are easy to verify before integrating it
into the universal multi-vendor lab.
