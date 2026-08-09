# LAB-001 — Solution Guide

Open this file only after completing `TASK-ONLY.md` or when you are genuinely blocked.

## Task 0 — Baseline

Deploy from the directory containing `lab001.clab.yml`:

```text
containerlab destroy -t lab001.clab.yml --cleanup
containerlab deploy -t lab001.clab.yml
docker logs -f r1
```

Wait for Junos startup to complete, then open management and console sessions:

```text
ssh admin@r1
docker exec -it r1 telnet 127.0.0.1 5000
```

Run the baseline data-plane test from the host:

```text
chmod +x scripts/verify.sh
./scripts/verify.sh
```

Collect the R1 baseline:

```text
show version
show system uptime
show system users
show system commit
show interfaces terse
show route 192.168.10.0/24 exact
show route 10.0.12.0/30 exact
show route 10.255.0.1/32 exact
```

Expected client reachability:

| Destination | Expected |
|---|---|
| 192.168.10.1 | Reachable |
| 10.0.12.2 | Reachable |
| 10.255.0.1 | Reachable |
| 10.255.0.2 | Reachable through R1 and R2 return route |

## Task 1 — Candidate versus active

```text
configure
set system location building JNCIE-LAB
set system location floor LAB-001
set interfaces ge-0/0/1 description SP-CORE-LINK
show | compare
run show configuration system location
run show configuration interfaces ge-0/0/1
rollback 0
show | compare
```

`show` in configuration mode reads the candidate view. `run show configuration` reads the committed configuration through operational mode. `rollback 0` reloads the current active configuration into the candidate, thereby discarding uncommitted changes.

## Task 2 — Validation failure

```text
set policy-options policy-statement LAB001-TEST term 10 from prefix-list LAB001-PREFIXES
set policy-options policy-statement LAB001-TEST term 10 then accept
commit check
set policy-options prefix-list LAB001-PREFIXES 192.0.2.0/24
commit check
show | compare
commit comment "LAB-001: create isolated policy validation example"
run show system commit
```

The first validation should fail because the referenced prefix list is undefined. A successful `commit check` proves configuration validation, not service correctness. Operational post-checks remain mandatory.

## Task 3 — Automatic rollback

First attempt, intentionally allow rollback:

```text
set system location rack RACK-01
show | compare
commit check
commit confirmed 3
run show system commit
run show configuration system location
```

After the timeout:

```text
run show configuration system location
run show system commit
```

Second attempt, confirm after verification:

```text
set system location rack RACK-01
commit confirmed 3 comment "LAB-001: temporary rack change"
run show configuration system location
commit comment "LAB-001: confirm verified rack change"
```

A confirmed commit is active during the confirmation interval. An ordinary `commit` before the deadline confirms it permanently. If not confirmed, Junos automatically restores the preceding committed configuration.

## Task 4 — Management-loss simulation

Pre-check:

```text
show system users
show interfaces ge-0/0/0 terse
show route 192.168.10.0/24 exact
show system commit
```

Change:

```text
configure
delete interfaces ge-0/0/0 unit 0 family inet address 192.168.10.1/24
set interfaces ge-0/0/0 unit 0 family inet address 192.168.99.1/24
show | compare
commit check
commit confirmed 2 comment "LAB-001: management-loss recovery test"
```

From the console, observe:

```text
show system commit
show interfaces ge-0/0/0 terse
```

After timeout, expected state:

```text
show interfaces ge-0/0/0 terse
show configuration interfaces ge-0/0/0
```

`192.168.10.1/24` should return, and `scripts/verify.sh` should pass again. If you use an ordinary commit, no automatic recovery timer exists and console/manual rollback is required.

## Task 5 — Manual rollback

```text
configure
set system location rack RACK-01
commit comment "LAB-001: rack revision 1"
set system location rack RACK-02
commit comment "LAB-001: rack revision 2"
set system location rack RACK-03
commit comment "LAB-001: rack revision 3"
run show system commit
rollback 1
show | compare
commit check
commit comment "LAB-001: restore preceding rack revision"
rollback 2
show | compare
rollback 0
show | compare
```

Loading a rollback modifies only the candidate. The loaded revision becomes active only after commit. Rollback zero represents the currently active committed configuration.

## Task 6 — Rescue configuration

Save the current known-good configuration from operational mode:

```text
request system configuration rescue save
show system configuration rescue
```

Create and restore an intentional bad value:

```text
configure
set system location rack WRONG-RACK
commit comment "LAB-001: intentional rescue test"
rollback rescue
show | compare
commit check
commit comment "LAB-001: restore known-good rescue configuration"
```

Rollback history is chronological and changes after every commit. Rescue is an explicitly saved known-good checkpoint. A stale rescue configuration can remove legitimate changes made after it was saved, so always inspect the diff before committing a rescue restoration.

## Task 7 — Concurrent sessions

### Shared

Session A:

```text
configure
set system location building SHARED-A
show | compare
```

Session B:

```text
configure
show | compare
```

Both sessions operate on the shared candidate, so session B should see session A's uncommitted change. Clean up from either session:

```text
rollback 0
exit
```

### Exclusive

```text
configure exclusive
```

Keep session A in exclusive mode. In session B, run `configure` and record the lock error. In session A, identify users and release the lock:

```text
run show system users
exit
```

### Private

```text
configure private
```

Session A:

```text
configure private
set system location building PRIVATE-A
show | compare
commit comment "LAB-001: private session A"
```

Session B:

```text
configure private
set system location floor PRIVATE-B
show | compare
commit check
commit comment "LAB-001: private session B"
```

Repeat with both sessions changing `system location rack` to different values. Commit session A first; then run `show | compare` and `commit check` in session B and record the conflict or merge result before cleanup. Each private candidate is derived from committed configuration, and Junos rejects changes it cannot merge safely.

## Final assessment reference workflow

```text
show interfaces ge-0/0/1 extensive
show route 10.0.12.0/30 exact
ping 10.0.12.2 rapid count 5
configure exclusive
set interfaces ge-0/0/1 description PROD-CORE-R1-R2
show | compare
commit check
commit confirmed 3 comment "LAB-001: change R1-R2 link description"
run show interfaces ge-0/0/1 descriptions
run ping 10.0.12.2 rapid count 5
commit comment "LAB-001: confirm verified R1-R2 description"
run show system commit
```

The interface-description change is low risk, but using the complete workflow builds the habit required for higher-risk production changes.

## Mastery check

You have mastered LAB-001 when you can explain and demonstrate all of the following without the guide:

1. Candidate versus active configuration
2. `commit check` versus operational verification
3. Confirmed commit activation and confirmation
4. Automatic rollback after management loss
5. Rollback zero and previous revisions
6. Rescue configuration lifecycle
7. Shared, exclusive and private edit sessions
8. Audit comments, evidence collection and post-checks
