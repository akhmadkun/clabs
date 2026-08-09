# LAB-001 — Task-Only Workbook

## Safe Junos Configuration Workflow

Do not open `SOLUTION-GUIDE.md` until the assessment is complete.

## Scenario

You are responsible for R1, an SP edge router reachable through both Containerlab management and the in-band `192.168.10.0/24` network. A maintenance request requires configuration changes without losing recoverability or unintentionally overwriting another engineer's work.

Your objective is not merely to make the commands succeed. Demonstrate a controlled workflow consisting of pre-check, candidate review, validation, safe activation, operational verification and rollback readiness.

## Completion gate

Mark LAB-001 complete only if you can:

- Repeat the workflow without following a command recipe.
- Explain candidate versus active configuration.
- Recover automatically from a management-breaking change.
- Recover manually with rollback and rescue configuration.
- Explain shared, exclusive and private configuration sessions.
- Produce complete evidence for every milestone.

## Rules

1. Keep console access available before management fault injection.
2. Do not use `commit` until the task explicitly allows it.
3. Record `show | compare` before every commit operation.
4. Run control-plane and data-plane checks after every committed change.
5. Record hypotheses before troubleshooting.
6. Do not redeploy the lab to hide a failed recovery attempt.

---

## Task 0 — Deploy and baseline

1. Deploy `lab001.clab.yml`.
2. Wait until both Junos nodes are healthy.
3. Connect to R1 through its Containerlab management address.
4. Establish a separate console session to R1.
5. Verify all four destinations using `scripts/verify.sh`.
6. Record:
   - software version;
   - system uptime;
   - interface state;
   - route to each connected subnet;
   - current commit history;
   - logged-in users.

### Evidence

- Deployment output
- Baseline verification output
- R1 operational command output

---

## Task 1 — Candidate versus active configuration

On R1, place the following intended information in the candidate configuration without committing it:

- Building: `JNCIE-LAB`
- Floor: `LAB-001`
- R1-to-R2 interface description: `SP-CORE-LINK`

Prove that:

1. The candidate contains the change.
2. The active configuration does not yet contain the change.
3. Packet forwarding continues to use the active configuration.
4. Discarding the candidate removes all pending changes.

### Questions

1. Which database is modified in configuration mode?
2. Does editing a candidate immediately notify routing protocols?
3. What is the safest way to discard all uncommitted changes?

### Evidence

- Candidate configuration
- Candidate-to-active diff
- Active configuration from operational mode
- Verification before and after discarding the candidate

---

## Task 2 — Validation failure and commit audit trail

Create a policy named `LAB001-TEST` that references a prefix list that does not exist.

1. Validate without activating the configuration.
2. Capture the complete error.
3. Create the missing prefix list containing `192.0.2.0/24`.
4. Validate again.
5. Review the candidate diff.
6. Commit using an audit comment containing the lab ID and change purpose.
7. Prove the commit is present in history.

Do not apply the test policy to a routing protocol.

### Evidence

- Failed validation
- Corrected validation
- Diff
- Commit history and comment

---

## Task 3 — Automatic rollback

Add rack location `RACK-01`.

1. Activate it temporarily with a three-minute confirmation window.
2. Prove the value is active.
3. Identify the pending rollback deadline.
4. Do not confirm it.
5. Prove the value disappears after timeout.
6. Repeat the change.
7. This time, verify it and make it permanent before timeout.

### Questions

1. Is a confirmed commit active or merely staged?
2. What event makes the change permanent?
3. What happens when the session closes before confirmation?

---

## Task 4 — Management-loss simulation

Perform this task only with a working console session.

Client1 reaches R1 through `192.168.10.1`. Change R1's client-facing address to `192.168.99.1/24` using a two-minute automatic recovery window.

Requirements:

1. Perform and record pre-checks.
2. Review the exact diff.
3. Validate the candidate.
4. Activate it temporarily.
5. Prove client1 loses reachability.
6. Do not correct the address through console.
7. Observe the pending commit through console.
8. Prove the original address and reachability return automatically.

### Incident note

Record:

- Symptom
- Impact
- Initial hypothesis
- Evidence
- Recovery mechanism
- Post-recovery verification

---

## Task 5 — Manual rollback

Create and commit three distinct rack values, with a unique commit comment for each.

Then:

1. Display commit history.
2. Load the immediately preceding committed configuration into the candidate.
3. Review the reverse diff before activation.
4. Commit the rollback with an audit comment.
5. Load an older rollback revision and inspect it without activating it.
6. Return the candidate to the current active configuration.
7. Prove there is no remaining candidate diff.

### Questions

1. Does loading a rollback immediately change forwarding?
2. What does rollback zero represent?
3. Why must a rollback be reviewed before commit?

---

## Task 6 — Rescue configuration

1. Confirm the router is in a known-good state.
2. Save the known-good committed configuration as the rescue configuration.
3. Prove the rescue configuration exists.
4. Commit an intentionally incorrect rack value.
5. Load the rescue configuration into the candidate.
6. Inspect the diff.
7. Validate and commit the restoration with an audit comment.
8. Run the complete verification script.

### Questions

1. How is rescue different from rollback one?
2. When should rescue be refreshed?
3. What is the risk of restoring a stale rescue configuration?

---

## Task 7 — Concurrent configuration sessions

Open two SSH sessions to R1.

### Shared candidate

1. Enter standard configuration mode from both sessions.
2. Make a location change in session A without committing.
3. Determine whether session B can see it.
4. Discard all changes.

### Exclusive candidate

1. Acquire an exclusive configuration lock in session A.
2. Attempt to enter configuration mode from session B.
3. Record the result and identify the lock owner.

### Private candidates

1. Enter private configuration mode from both sessions.
2. Modify different location leaves.
3. Compare visibility between sessions.
4. Commit session A.
5. Review and commit session B.
6. Repeat using conflicting edits to the same leaf and document the result.

---

## Final assessment — Blind workflow

Without using the solution guide, perform this change request:

> Change the R1-to-R2 interface description to `PROD-CORE-R1-R2`. Maintain service availability, include an audit trail, and demonstrate rollback readiness.

Submit:

1. Change plan
2. Pre-check output
3. Candidate diff
4. Validation result
5. Activation method and justification
6. Post-check output
7. Rollback plan
8. Final commit history

## Scoring

| Dimension | Weight |
|---|---:|
| Candidate/active understanding | 10% |
| Safe commit workflow | 20% |
| Confirmed commit recovery | 20% |
| Manual rollback | 15% |
| Rescue configuration | 10% |
| Concurrent sessions | 10% |
| Operational verification | 10% |
| Documentation | 5% |

Pass requires at least 80% and no critical recovery or verification failure.

