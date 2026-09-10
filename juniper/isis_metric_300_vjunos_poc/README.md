# IS-IS Metric 300 PoC — vJunos-router 25.4R1.12

## Objective

Test Junos IS-IS behavior when `level 2 metric 300` is configured without `wide-metrics-only`, then compare it with `wide-metrics-only` enabled.

## Containerlab / image

- Kind: `juniper_vjunosrouter`
- Image: `vrnetlab/juniper_vjunos-router:25.4R1.12`
- Management is left to Containerlab/vJunos default configuration.
- Do not configure `fxp0`, management IP, root-authentication, or SSH in the startup configs.
- Containerlab documentation: https://containerlab.dev/manual/kinds/vr-vjunosrouter/

## Interface mapping

Containerlab documents:

- `eth0` = container management interface, transparently connected to vJunos VM management
- `eth1` = first data interface -> Junos `ge-0/0/0`
- `eth2` = second data interface -> Junos `ge-0/0/1`
- topology links can use Junos interface names directly, e.g. `R1:ge-0/0/0`

## Topology

R1 ---10--- R2 ---300--- R3

All links are Level 2 only.

Initial configuration deliberately does NOT enable `wide-metrics-only`.

## Management / SSH

Containerlab/vJunos-router comes with management services pre-provisioned.

Default documented credentials:

- username: `admin`
- password: `admin@123`

Wait for the vJunos-router container to fully boot; Containerlab documents that startup can take roughly 5–10 minutes.

Examples:

```bash
containerlab deploy -t topology.clab.yml
containerlab inspect -t topology.clab.yml
ssh admin@<R1-management-ip>
```

Or:

```bash
docker exec -it clab-isis-metric-300-vjunos-R1 cli
```

## Verify initial state

On R2:

```text
show configuration protocols isis
show isis interface extensive
show isis adjacency
```

On R3:

```text
show route 1.1.1.1
show isis database
```

On all routers:

```text
show route protocol isis
show isis interface extensive
```

## Experiment A — metric 300 without wide-metrics-only

R2 contains:

```text
level 2 {
    metric 300;
}
```

No `wide-metrics-only` is configured.

Check what Junos actually installs/advertises:

```text
show isis interface ge-0/0/1.0 extensive
show isis database extensive
```

The purpose is to observe whether the operational metric is constrained to narrow-metric behavior.

## Experiment B — enable wide metrics

On R2:

```text
configure
set protocols isis level 2 wide-metrics-only
commit
```

Then verify again:

```text
show isis interface ge-0/0/1.0 extensive
show isis database extensive
```

Compare the generated metric/TLVs before and after `wide-metrics-only`.

## References

Official Containerlab vJunos-router documentation:
https://containerlab.dev/manual/kinds/vr-vjunosrouter/

Official Juniper vJunos-router documentation:
https://www.juniper.net/documentation/us/en/software/vjunos-router/

Official Juniper IS-IS metric CLI reference:
https://www.juniper.net/documentation/us/en/software/junos/cli-reference/topics/ref/statement/metric-edit-protocols-isis.html

Official Juniper IS-IS wide metrics example:
https://www.juniper.net/documentation/us/en/software/junos/is-is/topics/example/isis-wide-metrics.html
