# SYS-101 - Initial System Settings

This lab recreates the essential learning objectives of the JNCIE-SP workbook
Initial System Settings task using four vJunos-router nodes and one consolidated
services container.

## Objectives

- Build a secure Junos management baseline.
- Configure Syslog first so later troubleshooting is recorded.
- Configure management services and a retained management route.
- Configure DNS, time zone, and authenticated NTP.
- Archive configuration over SCP after each commit.
- Map RADIUS users to local authorization templates.
- Use RADIUS first with local password fallback.

## Credentials

- Bootstrap Junos account: `lab / lab123`
- Services SSH/SCP account: `lab / lab123`
- RADIUS users: `ops / ops123`, `noc / noc123`, `readonly / readonly123`
- RADIUS shared secret: `workbook`
- NTP authentication key: `workbook`

These credentials are intentionally lab-only and must not be reused elsewhere.

## Management addressing

Containerlab injects the management address, gateway, `management-instance`, and
`mgmt_junos` configuration into each vJunos-router. The startup configurations
deliberately do not configure those objects. Inside each VM, `fxp0.0` is
`10.0.0.15/24`; the addresses below are the host-facing management addresses.

| Node | Management address |
| --- | --- |
| R1 | `172.31.1.11` |
| R2 | `172.31.1.12` |
| R3 | `172.31.1.13` |
| R4 | `172.31.1.14` |
| S1 | `172.31.1.100` |

## Quick start

```bash
make validate
make build
make deploy
containerlab inspect -t topology.clab.yml
```

Attempt `docs/SYS-101_TASK-ONLY.pdf` before opening the solution guide.

After completing all tasks:

```bash
make verify
```

The final line must be:

```text
RESULT: PASS
```

Destroy the lab with `make destroy`.
