# SYS-101 - Initial System Settings

## Task-Only Assessment — Revision 3

**Platform:** Containerlab with four vJunos-router nodes and one services node  
**Time limit:** 3 hours  
**Target repetitions:** 2

## Rules

- Do not open the solution guide before completing the first attempt.
- Preserve management access throughout the exercise.
- Use `commit confirmed` before AAA-sensitive changes.
- Record the requested evidence under `evidence/`.
- Do not reuse the lab credentials outside this isolated environment.

## Addressing

| Node | Containerlab management IP | Loopback | Required hostname | Role |
|---|---:|---:|---|---|
| R1 | 172.31.1.11/24 | 192.0.2.11/32 | R1 | Junos router |
| R2 | 172.31.1.12/24 | 192.0.2.12/32 | R2 | Junos router |
| R3 | 172.31.1.13/24 | 192.0.2.13/32 | R3 | Junos router |
| R4 | 172.31.1.14/24 | 192.0.2.14/32 | R4 | Junos router |
| S1 | 172.31.1.100/24 | — | S1 | DNS, NTP, RADIUS, Syslog and SCP archive |

> Containerlab/vrnetlab injects management addressing, `management-instance`,
> `mgmt_junos`, and its default route. Do not configure them in startup files.
> The vJunos management interface visible inside each VM is `fxp0.0` at
> `10.0.0.15/24`, with management next hop `10.0.0.2`.

## Task 1 - Validate baseline and identity

### Objective

Confirm startup configuration loading, injected management connectivity, S1
reachability, and production identity.

### Requirements

1. Deploy all five nodes and verify that they are operational.
2. Confirm Containerlab management addresses and the injected `fxp0.0` configuration.
3. Change bootstrap hostnames to R1, R2, R3, and R4.
4. Save deployment and management-interface evidence.

## Task 2 - Central and local Syslog

### Objective

Create troubleshooting evidence before implementing the remaining tasks.

### Requirements

1. `jncie-sp-messages` must record information and interactive commands.
2. `user-commands` must record interactive commands.
3. S1 must receive notice messages and configuration changes through `mgmt_junos`.
4. User `ops` must receive warning messages when that user is logged in.
5. Archive three local files with a size of 100 KB each.

## Task 3 - Management services and retained route

### Objective

Enable required management protocols and preserve a remote management route if
RPD is unavailable.

### Requirements

1. Enable SSH, Telnet, and FTP.
2. Install `10.10.10.0/24` through `10.0.0.2` in `mgmt_junos`.
3. Retain the route if RPD stops.
4. Prevent the route from being advertised by dynamic routing protocols.

## Task 4 - DNS and time zone

### Objective

Provide consistent name resolution and administrative time display.

### Requirements

1. Use S1 as the DNS server through `mgmt_junos`.
2. Use domain `sys101.lab`.
3. Set `Europe/Amsterdam` as the time zone.
4. Resolve and reach `s1.sys101.lab` through `mgmt_junos`.

## Task 5 - Authenticated NTP

### Objective

Synchronize every router with S1 using authenticated NTP.

### Requirements

1. Configure the node-specific loopback address shown in the addressing table.
2. Use S1 as the operational NTP server through `mgmt_junos`.
3. Use MD5 key ID 1 and key value `workbook`.
4. Trust key ID 1 and associate it with S1.
5. Demonstrate an authenticated, reachable NTP association and synchronized status.

## Task 6 - Configuration archival over SCP

### Objective

Archive configuration automatically after every commit.

### Requirements

1. Use S1 SCP with `lab / lab123` through `mgmt_junos`.
2. Store files in `/srv/ftp/archive` on S1.
3. Configure transfer on commit.
4. Trigger at least one post-configuration archive.
5. Demonstrate a non-empty archived configuration on S1.

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

## Final acceptance

Run:

```bash
bash scripts/verify.sh
```

The last line must be `RESULT: PASS`. Preserve all evidence and record the
attempt in the JNCIE-SP progress tracker.
