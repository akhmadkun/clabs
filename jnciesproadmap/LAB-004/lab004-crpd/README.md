# LAB004 - cRPD Conversion PoC

This is a cRPD adaptation of the supplied `LAB004` vJunos-router lab.

## Source topology preserved

```text
client1 -- R1 -- R2 -- R4 -- server1
             \          /
              \-- R3 --/
```

The original vJunos-router lab uses four routers with OSPF, MPLS/LDP, and iBGP at the edge routers. Those protocol relationships, IP addressing, metrics, and client/server prefixes are preserved; only the Junos interface names and Containerlab node kind/image are changed.

## cRPD platform

- Containerlab kind: `juniper_crpd`
- Image: `xzjt/crpd:25.2R1-S1.4`
- Management: `eth0` (containerlab management network)
- Data interfaces: `eth1`, `eth2`, `eth3`
- Startup configuration is supplied with `startup-config`.

For cRPD, Containerlab documents `eth0` as the management interface and `eth1` as the first data interface. Additional data interfaces follow as `eth2+`. The cRPD kind mounts a supplied startup config as `/config/juniper.conf` and uses it at boot.

## Interface mapping from the original vJunos lab

| Original vJunos interface | cRPD interface |
|---|---|
| ge-0/0/0 | eth1 |
| ge-0/0/1 | eth2 |
| ge-0/0/2 | eth3 |
| lo0.0 | lo0.0 |

## Deployment

```bash
containerlab deploy -t lab004-crpd.clab.yml
```

Check nodes:

```bash
containerlab inspect -t lab004-crpd.clab.yml
```

Access a router:

```bash
docker exec -it clab-lab004-crpd-r1 cli
```

## Verification

```bash
./verify.sh
```

Useful checks:

```text
show interfaces terse
show ospf neighbor
show route protocol ospf
show ldp session
show route table inet.3
show bgp summary
show route protocol bgp
```

## Important licensing note

The supplied cRPD image may be running without an installed license. A command being available does not prove that the corresponding feature is licensed. This PoC is intended to test what actually works in the image. In particular, MPLS/LDP and other advanced features should be validated with a functional protocol test rather than inferred from CLI availability.

## Differences / caveats

cRPD is not a 1:1 data-plane replacement for vJunos-router. It is a containerized routing daemon and has platform-specific forwarding limitations. Therefore this lab is primarily a control-plane and routing-protocol compatibility test.
