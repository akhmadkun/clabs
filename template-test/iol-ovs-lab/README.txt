IOL + Open vSwitch Containerlab Test Lab
========================================

Topology:

R1 Ethernet0/1 ---\
R2 Ethernet0/1 ---- OVS bridge 'ovs' ---- all VLANs allowed
R3 Ethernet0/1 ---/

Requirements
------------
- Linux host
- Open vSwitch installed and running
- Containerlab
- Cisco IOL image available locally / from your registry

1. Create the OVS bridge
------------------------
sudo ./setup-ovs.sh

2. Verify the bridge exists
---------------------------
sudo ovs-vsctl show

3. Deploy containerlab
----------------------
sudo containerlab deploy -t iol-ovs.clab.yml

4. Check links
--------------
sudo containerlab inspect -t iol-ovs.clab.yml
sudo ovs-vsctl show

5. Test from R1/R2/R3
---------------------
ssh admin@clab-iol-ovs-r1

R1# ping 10.255.0.2
R1# ping 10.255.0.3

R2# ping 10.255.0.1
R2# ping 10.255.0.3

6. Verify trunk/all-VLAN behavior in OVS
----------------------------------------
sudo ovs-vsctl list Port ovsp1
sudo ovs-vsctl list Port ovsp2
sudo ovs-vsctl list Port ovsp3

For a trunk port, vlan_mode=trunk with an empty trunks column permits all VLANs.

7. Cleanup
----------
sudo containerlab destroy -t iol-ovs.clab.yml
sudo ovs-vsctl del-br ovs

Notes
-----
- Cisco IOL data-plane interface naming follows containerlab's official cisco_iol kind:
  Ethernet0/1, Ethernet0/2, Ethernet0/3, Ethernet1/0, ...
- Ethernet0/0 is the management interface and is not used in this topology.
- The startup configs are partial configs so containerlab's generated management
  configuration is retained.
