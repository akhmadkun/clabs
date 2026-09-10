# JNCIE-SP Universal Physical Topology

Components:
- 10 x vJunos-router 25.4R1.12-rcvmm
- 1 x Arista EOS ceos:4.35.0F
- 2 x network-multitool
- One physical trunk from each endpoint to the Arista
- Logical adjacencies are created with VLANs

VLAN pools:
- 101-199: core / point-to-point
- 201-299: alternate / IPv6
- 301-399: MPLS / SR / TE
- 401-499: L2VPN / EVPN / service
- 501-599: special scenarios

Deploy:
  containerlab deploy -t jncie-sp-universal.clab.yml

The topology is deliberately role-neutral. R1-R10 can become P, PE, RR,
ASBR, or CE through Junos configuration.
