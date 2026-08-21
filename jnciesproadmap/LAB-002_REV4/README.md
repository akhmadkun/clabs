# LAB-002 - Hierarchy, Inheritance and Groups

This package follows LAB-001 and trains reusable Junos configuration, inherited statements, `apply-groups-except`, interface ranges, precedence, and safe rollback.

## Deploy

```bash
containerlab destroy -t lab002.clab.yml --cleanup
containerlab deploy -t lab002.clab.yml
chmod +x scripts/verify.sh
./scripts/verify.sh
```

Wait until all vJunos routers finish booting. Login is `admin` / `admin@123`.

## Required baseline gate

On every router, confirm the hostname, physical addresses, loopback, and static routes are present. On R1, verify exact routes to `10.255.0.2/32` and `10.255.0.3/32`. The verification script must end with `RESULT: PASS` before starting Task 1.

Use `TASK-ONLY.pdf` first. Open `SOLUTION-GUIDE.pdf` or the editable DOCX only after completing the assessment or when genuinely blocked.
