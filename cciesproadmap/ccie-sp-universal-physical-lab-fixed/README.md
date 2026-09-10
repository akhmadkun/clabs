# CCIE-SP Universal Physical Lab

## Fixed physical topology

- 10 x Cisco XRd: `sbezverk/xrd-control-plane:25.2.1`
- 1 x Arista EOS: `ceos:4.35.0F`
- 2 x Linux multitool: `ghcr.io/srl-labs/network-multitool:latest`

`prefix: ""` is used so container names/node names remain simple (`r1`, `r2`,
..., `sw1`) rather than gaining the default `clab-ccie_sp_universal-` prefix.

XRd containerlab link endpoints use the required topology naming format:
`Gi0-0-0-X`. For example:

  sw1:eth1 <-> r1:Gi0-0-0-0

Inside IOS XR the interface is presented as:
`GigabitEthernet0/0/0/0`.

## Logical topology model

The Arista is a permanent Layer-2 / 802.1Q backplane.

VLAN pools:
- 101-199: core / IPv4 underlay
- 201-299: alternate / IPv6
- 301-399: MPLS / SR / TE
- 401-499: L2VPN / EVPN / services
- 501-599: special / test segments

Logical adjacency is created by configuring the same VLAN ID on the two XRd
routers that should be connected.

## XRd multi-config storage

Each XRd binds:

`./configs/rN:/misc/config/labconfigs:ro`

Inside IOS XR, this is proven visible as:

`disk0:/config/labconfigs/`

Scenario configs can therefore be loaded natively from IOS XR without
restarting or redeploying the topology.

## Deploy

containerlab deploy -t ccie-sp-universal.clab.yml
