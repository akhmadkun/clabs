PALO ALTO + NEXUS vPC + SELECTIVE PBR
POC-002 — Normal Nexus Routing -> PBR Service Insertion
=========================================================

OBJECTIVE
---------
First prove that inter-VLAN traffic is routed directly by the Nexus pair.

Then configure Palo Alto as a one-arm service-insertion point:
- one AE on Palo Alto
- AE1 carries VLAN 100 and VLAN 200
- ae1.100 = INSIDE
- ae1.200 = OUTSIDE
- Nexus PBR redirects only selected traffic to the PA

TEST FLOWS
----------
Selected:
  10.100.100.10 -> 10.200.200.10

Non-selected:
  10.100.100.11 -> 10.200.200.10

Expected:
- before PBR: both flows use normal Nexus routing
- after PBR: selected flow traverses Palo Alto
- after PBR: non-selected flow still uses normal Nexus routing

IMAGES
------
N9K:
  arthurk99/cisco-nxos9000v:10.3.5

PA:
  vrnetlab/paloalto_pa-vm:11.2.5

Multitool:
  ghcr.io/srl-labs/network-multitool:latest

IP PLAN
-------
Management:
  N9K-01  172.30.30.11
  N9K-02  172.30.30.12
  PA-01   172.30.30.13

vPC:
  Domain 10
  Po100 = peer-link
  Po20  = PA downstream vPC
  Keepalive:
    N9K-01 10.255.0.1/30
    N9K-02 10.255.0.2/30

VLAN 100:
  N9K-01 SVI 10.100.100.2/24
  N9K-02 SVI 10.100.100.3/24
  HSRP VIP 10.100.100.1
  PA ae1.100 10.100.100.254/24
  MT-INSIDE-PBR    10.100.100.10/24
  MT-INSIDE-NORMAL 10.100.100.11/24

VLAN 200:
  N9K-01 SVI 10.200.200.2/24
  N9K-02 SVI 10.200.200.3/24
  HSRP VIP 10.200.200.1
  PA ae1.200 10.200.200.254/24
  MT-OUTSIDE       10.200.200.10/24

DEPLOY
------
  ./preflight.sh
  containerlab deploy -t Palo_Nexus_vPC_PBR_PoC_002.clab.yml

PA-VM BOOT
----------
The PA-VM is a vrnetlab/QEMU VM. Allow time for full PAN-OS boot.

The PA configuration is intentionally manual in solution-guide.txt.

VERIFY
------
  ./verify.sh

CLEANUP
-------
  containerlab destroy -t Palo_Nexus_vPC_PBR_PoC_002.clab.yml

NOTE
----
The Nexus startup configurations intentionally contain the baseline
(vPC + HSRP + VLANs + PA vPC downlink) but do not apply PBR.
PBR is added later during the lab so the student can clearly compare
normal forwarding against PBR forwarding.
