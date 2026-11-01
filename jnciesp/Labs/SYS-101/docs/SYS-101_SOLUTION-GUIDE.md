# SYS-101 - Initial System Settings

## Solution Guide — Revision 3

**Platform:** Containerlab, four `vJunos-router 25.4R1.12` nodes, one consolidated services node  
**Estimated time:** 3 hours | **Difficulty:** Intermediate | **Target repetitions:** 2

## Lab purpose

Build and verify a secure management baseline on R1-R4. Containerlab/vrnetlab
injects management addressing, `management-instance`, `mgmt_junos`, and its
default route. Startup files deliberately do not configure those objects.

## Addressing

| Node | Containerlab management IP | Loopback | Final hostname | Role |
|---|---:|---:|---|---|
| R1 | 172.31.1.11/24 | 192.0.2.11/32 | R1 | Junos router |
| R2 | 172.31.1.12/24 | 192.0.2.12/32 | R2 | Junos router |
| R3 | 172.31.1.13/24 | 192.0.2.13/32 | R3 | Junos router |
| R4 | 172.31.1.14/24 | 192.0.2.14/32 | R4 | Junos router |
| S1 | 172.31.1.100/24 | — | S1 | DNS, NTP, RADIUS, Syslog and SCP archive |

Inside each vJunos VM, `fxp0.0` is `10.0.0.15/24` and the management next hop
is `10.0.0.2`. The `172.31.1.x` addresses remain the Containerlab-facing
addresses used from the host and by S1.

## Task 1 - Validate baseline and identity

### Objective

Confirm startup configuration loading, injected management connectivity, S1
reachability, and production identity.

### Requirements

1. Deploy all five nodes and verify that they are operational.
2. Confirm Containerlab management addresses and the injected `fxp0.0` configuration.
3. Change bootstrap hostnames to R1, R2, R3, and R4.
4. Save deployment and management-interface evidence.

### Solution

Deploy and inspect the lab:

```bash
make build-services
make deploy
containerlab inspect --topo topology.clab.yml
```

On every router, replace `<NODE>` with its node name:

```text
configure
set system host-name <NODE>
commit confirmed 5
run show interfaces terse fxp0
run ping 172.31.1.100 routing-instance mgmt_junos count 3
commit
```

Do not add management configuration to the startup file. An internal address
such as `10.0.0.15/24` is expected on `fxp0.0`; the host still reaches the node
through the Containerlab address.

## Task 2 - Central and local Syslog

### Objective

Create troubleshooting evidence before implementing the remaining tasks.

### Requirements

1. `jncie-sp-messages` must record information and interactive commands.
2. `user-commands` must record interactive commands.
3. S1 must receive notice messages and configuration changes through `mgmt_junos`.
4. User `ops` must receive warning messages when that user is logged in.
5. Archive three local files with a size of 100 KB each.

### Solution

```text
configure
set system syslog archive size 100k
set system syslog archive files 3
set system syslog file jncie-sp-messages any info
set system syslog file jncie-sp-messages interactive-commands any
set system syslog file user-commands interactive-commands any
set system syslog host 172.31.1.100 any notice
set system syslog host 172.31.1.100 change-log any
set system syslog host 172.31.1.100 routing-instance mgmt_junos
set system syslog user ops any warning
commit
```

The `ops` target is valid before Task 7 creates the corresponding login
template. It becomes useful whenever that identity is logged in.

Verify locally and on S1:

```text
show configuration system syslog | display set
show log jncie-sp-messages | last 20
show log user-commands | last 20
```

```bash
find evidence/services -name '*.log' -size +0c -ls
```

## Task 3 - Management services and retained route

### Objective

Enable required management protocols and preserve a remote management route if
RPD is unavailable.

### Requirements

1. Enable SSH, Telnet, and FTP.
2. Install `10.10.10.0/24` through `10.0.0.2` in `mgmt_junos`.
3. Retain the route if RPD stops.
4. Prevent the route from being advertised by dynamic routing protocols.

### Solution

```text
configure
set system services ssh
set system services telnet
set system services ftp
set routing-instances mgmt_junos routing-options static route 10.10.10.0/24 next-hop 10.0.0.2
set routing-instances mgmt_junos routing-options static route 10.10.10.0/24 retain
set routing-instances mgmt_junos routing-options static route 10.10.10.0/24 no-readvertise
commit confirmed 5
run show route table mgmt_junos.inet.0 10.10.10.0/24 exact detail
commit
```

`retain` preserves forwarding state when RPD is unavailable;
`no-readvertise` prevents redistribution into dynamic routing protocols.

## Task 4 - DNS and time zone

### Objective

Provide consistent name resolution and administrative time display.

### Requirements

1. Use S1 as the DNS server through `mgmt_junos`.
2. Use domain `sys101.lab`.
3. Set `Europe/Amsterdam` as the time zone.
4. Resolve and reach `s1.sys101.lab` through `mgmt_junos`.

### Solution

```text
configure
set system name-server 172.31.1.100 routing-instance mgmt_junos
set system domain-name sys101.lab
set system time-zone Europe/Amsterdam
commit
run ping s1.sys101.lab routing-instance mgmt_junos count 3
```

The expected DNS answer is `172.31.1.100`. If an older address is returned,
rebuild S1 without cache and redeploy it.

## Task 5 - Authenticated NTP

### Objective

Synchronize every router with S1 using authenticated NTP.

### Requirements

1. Configure the node-specific loopback address shown in the addressing table.
2. Use S1 as the operational NTP server through `mgmt_junos`.
3. Use MD5 key ID 1 and key value `workbook`.
4. Trust key ID 1 and associate it with S1.
5. Demonstrate an authenticated, reachable NTP association and synchronized status.

### Solution

On each router, replace `<LOOPBACK>` with the address from the table:

```text
configure
set interfaces lo0 unit 0 family inet address <LOOPBACK>
set system ntp authentication-key 1 type md5 value
set system ntp trusted-key 1
set system ntp server 172.31.1.100 key 1 routing-instance mgmt_junos
commit
```

Enter `workbook` when prompted. `boot-server` is not available in Junos
25.4R1.12 and is intentionally omitted. The loopback supplies a usable source
identity for this platform combination.

```text
show configuration system ntp | display set | except value
show ntp associations
show ntp status
```

Wait for nonzero reach and `sync_ntp`. The association should show `SKEY`.

## Task 6 - Configuration archival over SCP

### Objective

Archive configuration automatically after every commit.

### Requirements

1. Use S1 SCP with `lab / lab123` through `mgmt_junos`.
2. Store files in `/srv/ftp/archive` on S1.
3. Configure transfer on commit.
4. Trigger at least one post-configuration archive.
5. Demonstrate a non-empty archived configuration on S1.

### Solution

```text
configure
set system archival configuration transfer-on-commit
set system archival configuration routing-instance mgmt_junos
set system archival configuration archive-sites "scp://lab@172.31.1.100/srv/ftp/archive" password
commit
```

Enter `lab123` when prompted, then make one harmless committed change. Verify:

```text
show configuration system archival
show log messages | match transfer
```

```bash
find services/archive -type f -size +0c -ls
```

The tested vJunos FTP client rejects the internal routing-instance option.
SCP is therefore the supported lab method. For manual testing:

```text
file copy /config/juniper.conf.gz scp://lab@172.31.1.100/srv/ftp/archive/R1-test.conf.gz routing-instance mgmt_junos
```

## Task 7 - Authorization classes and RADIUS mappings

### Objective

Map RADIUS identities to distinct Junos authorization profiles.

### Requirements

1. `ops-class` must have clear, network, reset, trace, and view permissions.
2. `noc-class` must have all permissions but deny clear, configure, edit, and start-shell commands.
3. Create local passwordless templates `radius-ops` and `radius-noc` for the two classes.
4. Create local passwordless template `remote` with read-only authorization.
5. Map RADIUS users `ops` and `noc` to their corresponding local templates with `Juniper-Local-User-Name`.
6. Demonstrate permitted and denied actions for each constrained role and read-only authorization for an unmapped RADIUS user.

### Solution

```text
configure
set system login class ops-class permissions clear
set system login class ops-class permissions network
set system login class ops-class permissions reset
set system login class ops-class permissions trace
set system login class ops-class permissions view
set system login class noc-class permissions all
set system login class noc-class deny-commands "(clear|configure|edit|start shell)"
set system login user radius-ops class ops-class
set system login user radius-noc class noc-class
set system login user remote class read-only
commit
```

These are passwordless local authorization templates, not duplicate local
credentials. S1 returns these FreeRADIUS attributes:

```text
ops Cleartext-Password := "ops123"
    Juniper-Local-User-Name := "radius-ops"

noc Cleartext-Password := "noc123"
    Juniper-Local-User-Name := "radius-noc"

readonly Cleartext-Password := "readonly123"
```

The unmapped `readonly` identity inherits the special `remote` template. Test
both permitted and denied commands after Task 8 activates RADIUS.

## Task 8 - RADIUS authentication with local fallback

### Objective

Use centralized authentication first while maintaining local recovery access.

### Requirements

1. Authentication order must be RADIUS followed by local password.
2. Use S1 through `mgmt_junos` with shared secret `workbook`.
3. Set retry to 1 and timeout to 2 seconds.
4. Preserve local break-glass user `lab / lab123`.
5. Prove RADIUS authentication while S1 is available.
6. Prove local fallback while S1 RADIUS is unavailable without causing administrative lockout.

### Solution

Keep the current session open:

```text
configure
set system authentication-order radius
set system authentication-order password
set system radius-server 172.31.1.100 secret
set system radius-server 172.31.1.100 routing-instance mgmt_junos
set system radius-server 172.31.1.100 retry 1
set system radius-server 172.31.1.100 timeout 2
commit confirmed 10
```

Enter `workbook`, then prove login as `ops`, `noc`, and `readonly` from a second
terminal. Confirm the commit only after successful tests.

To prove local fallback, temporarily stop RADIUS without removing S1:

```bash
docker exec S1 supervisorctl stop radius
ssh lab@R3
docker exec S1 supervisorctl start radius
```

`lab / lab123` must work while RADIUS is stopped. This proves password fallback;
a normal local login while RADIUS is reachable does not prove which method was
used. Verify RADIUS traffic/logs on S1 when needed.

## Final verification

```bash
bash scripts/verify.sh
```

Required final line:

```text
RESULT: PASS
```

## Rollback and reset

```bash
make destroy
make deploy
```

`enforce-startup-config: true` reloads the supplied bootstrap baseline on a
clean deployment; Containerlab injects the management plane again.
