PALO ALTO + NEXUS vPC/LACP PoC
POC-001 — True VM-Series AE/LACP to Nexus vPC
================================================

LAB INTENT
----------
This PoC validates a dual-homed Palo Alto VM-Series design:

  N9K-01 ---------------- N9K-02
       \                  /
        \==== vPC/LACP ==/
             PA-VM

The PA-VM uses two Aggregate Ethernet interfaces:
  AE1 = INSIDE
  AE2 = OUTSIDE

Each AE has one member on N9K-01 and one member on N9K-02.

SUPPLIED IMAGES
---------------
Nexus:
  arthurk99/cisco-nxos9000v:10.3.5

Palo Alto:
  vrnetlab/paloalto_pa-vm:11.2.5

Clients:
  ghcr.io/srl-labs/network-multitool:latest

IMPORTANT SOFTWARE NOTE
-----------------------
VM-Series link aggregation was introduced in PAN-OS 11.1.0. PAN-OS 11.2
supports Aggregate Ethernet with LACP, including Layer 3 AE interfaces.

Palo Alto's VM-Series KVM LACP documentation lists a VM-Series firewall
license (BYOL), Panorama, and the VM-Series plugin as prerequisites for the
KVM deployment workflow. In this PoC the VM itself is orchestrated by
Containerlab/vrnetlab. If AE/LACP is not available on the VM, check the
VM-Series license/plugin/feature state before changing the topology.

CONTAINERLAB
------------
PA-VM and Nexus 9000v are VM-based vrnetlab nodes managed by Containerlab.
The Containerlab PA-VM documentation notes that a PA-VM can take about
8 minutes to fully boot. Monitor with docker logs during startup.

RESOURCE NOTE
-------------
Containerlab's current N9kv documentation says the default N9kv VM uses
about 10 GB RAM and 4 vCPU. Tune QEMU_MEMORY/QEMU_SMP only when needed and
only after checking the behavior of your exact Nexus image.

IP PLAN
-------
Management:
  N9K-01      172.30.30.11/24
  N9K-02      172.30.30.12/24
  PA-01       172.30.30.13/24

Data plane:
  VLAN 100    INSIDE
  PA AE1      10.100.100.1/24
  MT-INSIDE   10.100.100.10/24

  VLAN 200    OUTSIDE
  PA AE2      10.200.200.1/24
  MT-OUTSIDE  10.200.200.10/24

vPC:
  Domain      10
  Peer-link   Po100
  Keepalive   N9K-01 10.255.0.1/30
              N9K-02 10.255.0.2/30

Downstream vPCs:
  vPC 20 = PA AE1 / VLAN 100
  vPC 21 = PA AE2 / VLAN 200
  vPC 30 = MT-INSIDE / VLAN 100
  vPC 40 = MT-OUTSIDE / VLAN 200

TOPOLOGY / PA INTERFACES
-------------------------
PA Ethernet1/1 -> N9K-01 Ethernet1/4 -> Po20 vPC20 -> PA AE1
PA Ethernet1/2 -> N9K-02 Ethernet1/4 -> Po20 vPC20 -> PA AE1

PA Ethernet1/3 -> N9K-01 Ethernet1/5 -> Po21 vPC21 -> PA AE2
PA Ethernet1/4 -> N9K-02 Ethernet1/5 -> Po21 vPC21 -> PA AE2

The Nexus port-channels facing the PA are Layer 2 access port-channels.
The PA AE interfaces are Layer 3.

DEPLOY
------
1. Confirm images:
     docker image inspect arthurk99/cisco-nxos9000v:10.3.5
     docker image inspect vrnetlab/paloalto_pa-vm:11.2.5
     docker image inspect ghcr.io/srl-labs/network-multitool:latest

2. Deploy:
     containerlab deploy -t Palo_Nexus_vPC_LACP_PoC_001.clab.yml

3. Verify:
     containerlab inspect -t Palo_Nexus_vPC_LACP_PoC_001.clab.yml

4. PA-VM boot log:
     docker logs -f clab-palo-nexus-vpc-lacp-poc-pa-01

5. Follow solution-guide.txt.

6. Run:
     ./verify.sh

DESTROY
-------
  containerlab destroy -t Palo_Nexus_vPC_LACP_PoC_001.clab.yml

DESIGN SCOPE
------------
This is a standalone PA PoC. No Palo Alto HA is included yet.
After this is stable, the next natural PoC is:
  PA-01 + PA-02 HA Active/Passive
  + LACP pre-negotiation
  + vPC/LACP failover
