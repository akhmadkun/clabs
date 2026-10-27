LAB-007 - OSPF INTERFACE TYPES & ADJACENCY
Default image: xzjt/crpd:25.2R1-S1.4
Source: Junos OS OSPF User Guide, Chapter 3 (Configure OSPF Interfaces) and Chapter 4 (DR election).

DESIGN
This is a feature-focused lab that assumes a working OSPF baseline. It uses the existing universal topology and external bridge br-univ; it must not create, delete, or recreate br-univ.
VLAN 12 is a shared broadcast segment with R1, R2 and R3. VLAN 13 is a separate R1-R3 point-to-point test link.
The shared VLAN 12 segment requires R3 to join VLAN 12 at Layer 2. If the universal topology currently attaches only R1 and R2 to VLAN 12, add R3's eth1.12 attachment to the same shared VLAN segment before using this profile.
Do not run another OSPF lab using overlapping VLANs/IPs at the same time.

PROFILE USAGE
configs/*.set files use Junos "set" format. They are reference baseline profiles for a clean LAB-007 context, not a blind merge into an unrelated live router configuration. Adapt the interface/IP lines if your universal topology differs.
No live deployment was run while building this package. Verify with commit check and operational commands on your PC.
