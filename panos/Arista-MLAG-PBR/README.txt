PALO ALTO + ARISTA MLAG + SELECTIVE PBR
POC-001 — Normal Routing -> PBR Service Insertion
===================================================

Images:
  ceos:4.35.0F
  vrnetlab/paloalto_pa-vm:11.2.5
  ghcr.io/srl-labs/network-multitool:latest

Architecture:
  ARISTA-01 ===== MLAG peer-link ===== ARISTA-02
        \            Po20            /
         \========= MLAG20 =========/
                     |
                  PA AE1
               /            \
          ae1.100          ae1.200
           INSIDE           OUTSIDE

Lab phases:
  1. MLAG + VARP + normal inter-VLAN routing
  2. PA one-AE trunk with two L3 subinterfaces
  3. selective PBR from Vlan100 to PA
  4. reverse PBR from Vlan200 to PA
  5. prove non-selected traffic still uses normal routing
  6. test PA AE member failure

Management:
  ARISTA-01 172.30.40.11
  ARISTA-02 172.30.40.12
  PA-01      172.30.40.13

MLAG:
  Vlan4094: 172.31.254.1/30 <-> 172.31.254.2/30
  Po100 peer-link
  MLAG domain MLAG-PALO-01
  Po20 / MLAG20 -> PA AE1

Data:
  Vlan100 INSIDE
    VARP 10.100.100.1
    ARISTA-01 10.100.100.2
    ARISTA-02 10.100.100.3
    PA ae1.100 10.100.100.254
    selected host 10.100.100.10
    normal host 10.100.100.11

  Vlan200 OUTSIDE
    VARP 10.200.200.1
    ARISTA-01 10.200.200.2
    ARISTA-02 10.200.200.3
    PA ae1.200 10.200.200.254
    destination 10.200.200.10

PA:
  AE1
   e1/1 + e1/2
   ae1.100 10.100.100.254/24 INSIDE
   ae1.200 10.200.200.254/24 OUTSIDE

CLIENTS:
  selected = 10.100.100.10
  normal   = 10.100.100.11
  outside  = 10.200.200.10

PBR FWD:
  match .10 -> .10
  nexthop 10.100.100.254
  apply Vlan100 input

PBR REV:
  match .10 -> .10
  nexthop 10.200.200.254
  apply Vlan200 input

ARISTA VERIFY:
  show mlag
  show mlag config-sanity
  show mlag interfaces
  show port-channel summary
  show lacp neighbor
  show class-map type pbr
  show policy-map type pbr
  show ip access-lists PBR-FWD
  show ip access-lists PBR-REV

PA VERIFY:
  show interface ae1
  show lacp aggregate-ethernet ae1
  Monitor > Traffic


Deploy:
  ./preflight.sh
  containerlab deploy -t Palo_Arista_MLAG_PBR_PoC_001.clab.yml

Inspect:
  containerlab inspect -t Palo_Arista_MLAG_PBR_PoC_001.clab.yml

Verify:
  ./verify.sh

Destroy:
  containerlab destroy -t Palo_Arista_MLAG_PBR_PoC_001.clab.yml

NOTE:
The artifact was not deployed in the build environment. Run the deployment
on the lab PC for final validation.
