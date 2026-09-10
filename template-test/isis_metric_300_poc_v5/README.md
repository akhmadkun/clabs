# IS-IS Metric 300 PoC — Juniper cRPD 25.2R1-S1.4

## Goal
Test Junos IS-IS behavior when R2-R3 is configured with `level 2 metric 300` **without** `wide-metrics-only`.

## Image
`xzjt/crpd:25.2R1-S1.4`

## Containerlab interface mapping
Per the official Containerlab `juniper_crpd` kind documentation:
- `eth0` = management interface; Containerlab provides the management address.
- `eth1` = first data interface.
- `eth2` = second data interface.

The startup configs intentionally do not configure `eth0`, fxp0, SSH, or root authentication. Containerlab provides the default SSH service and `root:clab123` credentials.

## Topology

R1 -- eth1 -- R2 -- eth2 -- R3

R1-R2: 10.0.12.0/30
R2-R3: 10.0.23.0/30

All links are IS-IS Level 2.

Configured metrics:
- R1 -> R2 = 10
- R2 -> R1 = 10
- R2 -> R3 = 300
- R3 -> R2 = 10

No `wide-metrics-only` is configured in the initial config.

## Deploy

```bash
containerlab destroy -t topology.clab.yml --cleanup
containerlab deploy -t topology.clab.yml
containerlab inspect -t topology.clab.yml
```

SSH:

```bash
ssh root@<R1-mgmt-ip>
# password: clab123
```

Or direct CLI:

```bash
docker exec -it clab-isis-metric-300-poc-R1 cli
```

## Initial verification

```text
show interfaces routing
show isis adjacency
show isis interface extensive
show isis database
show route
```

Pay special attention to the operational IS-IS metric on R2 `eth2.0`.

## Experiment 2

After the baseline test, enable wide metrics on the relevant IS-IS level:

```text
configure
set protocols isis level 2 wide-metrics-only
commit
```

Then repeat:

```text
show isis interface extensive
show route
show isis database
```

Compare the result with the baseline.

## References
- Containerlab official docs — Juniper cRPD: https://containerlab.dev/manual/kinds/crpd/
- Juniper cRPD Deployment Guide: https://www.juniper.net/documentation/us/en/software/crpd/crpd-deployment/crpd-deployment.pdf
- Juniper IS-IS User Guide: https://www.juniper.net/documentation/us/en/software/junos/is-is/is-is.pdf
