# LAB-001 — Safe Junos Configuration Workflow

This package contains a guided assessment for practicing safe Junos changes in a Containerlab environment.

## Files

- `lab001.clab.yml` — Containerlab topology
- `topology/LAB-001-topology.png` — topology diagram
- `configs/r1.conf` — R1 initial configuration
- `configs/r2.conf` — R2 initial configuration
- `TASK-ONLY.pdf` — student tasks without answers
- `SOLUTION-GUIDE.pdf` — task-by-task configuration and verification guide
- `scripts/verify.sh` — basic reachability verification

## Requirements

- Containerlab
- Docker
- KVM support on the Containerlab host
- `vrnetlab/juniper_vjunos-router:25.4R1.12`
- `ghcr.io/srl-labs/network-multitool:latest`

## Deploy

```bash
containerlab deploy -t lab001.clab.yml
```

vJunos-router can take several minutes to become healthy. Monitor it with:

```bash
docker logs -f r1
```

Connect to R1:

```bash
ssh admin@r1
```

Lab credentials are `admin / admin@123` (or `root / admin@123`).

The topology uses `prefix: ""`, so node names are `r1`, `r2`, and `client1`.

## Verify

```bash
chmod +x scripts/verify.sh
./scripts/verify.sh
```

## Destroy

```bash
containerlab destroy -t lab001.clab.yml --cleanup
```
