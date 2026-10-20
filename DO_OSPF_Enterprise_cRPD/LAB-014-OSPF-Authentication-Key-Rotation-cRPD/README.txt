LAB-014 — OSPF AUTHENTICATION, FAILURE ISOLATION & KEY ROTATION
Target platform: Juniper cRPD `crpd:23.4R2-S5.6`
Protocol scope: OSPFv2, IPv4, Area 0, point-to-point links

PURPOSE
This is not a password-syntax drill. The lab asks you to secure a four-router OSPF domain, deliberately create an authentication failure, isolate its cause using operational evidence, repair it, and optionally test a planned MD5 key rollover.

CORE LAB
1. Establish the four-router baseline.
2. Apply MD5 authentication on all four point-to-point adjacencies, using matching key ID and key on both ends of each link and distinct lab credentials per link.
3. Inject a key-ID mismatch on one end of R1-R3 while keeping the key text the same. Prove the adjacency fails, isolate the cause, and show the routing impact.
4. Restore matching authentication and prove all adjacencies and equal-cost paths recover.
5. Remove temporary authentication settings and return to the baseline profile.

OPTIONAL EXTENSION
Test a planned transition from an existing MD5 key to a second key using a future start-time. This depends on synchronized device clocks and cRPD feature support. Do not remove the old key until the new key is confirmed active and both sides remain Full. If the active key cannot be observed, classify the result as inconclusive and retain the old key until cleanup.

HOW TO USE THE PACKAGE
- `TASK.txt` is the challenge sheet; it describes objectives, constraints, and evidence without giving a command-by-command recipe.
- `SOLUTION-GUIDE.txt` contains the intended command sequence and expected behavior. Try the task first.
- `AUTH-KEY-MATRIX.txt` contains synthetic lab-only credentials and key IDs. Never reuse them outside this lab.
- `configs/rN/lab014-rN-baseline.set` creates the clean Area 0 diamond baseline and does not configure authentication.

TOPOLOGY AND SAFETY
- Reuse the existing universal Containerlab topology. Do not edit/redeploy its YAML for this lab.
- Use R1-R4 only. Their parent eth1 interfaces are attached to the pre-existing external `br-univ` bridge.
- Never create, delete, or recreate `br-univ`. Do not shut down parent interfaces for fault injection.
- Stop any other lab using these VLANs/IPs. Load only the matching baseline profile for each router after reading `CLEANUP-BEFORE-LAB014.txt`.
- A mismatch between OSPF authentication type, key ID, or shared key can prevent valid OSPF packets from being accepted. Changes are applied on both ends of each link; expect a temporary adjacency interruption while endpoints are updated.
- This cRPD lab verifies control-plane routing behavior only, not data-plane packet forwarding.

IMPORTANT SECURITY CONTEXT
Simple-password authentication sends a plain-text password and is not used in this lab. MD5 OSPF authentication is a legacy compatibility feature; it is not packet encryption and should not automatically be treated as a modern production security recommendation. Use only synthetic lab keys here. For production decisions, follow the vendor-supported cryptographic options and your organization's security standard.

CONTENTS
TASK.txt
SOLUTION-GUIDE.txt
ADDRESS-PLAN.txt
AUTH-KEY-MATRIX.txt
PROFILE-MAP.txt
CLEANUP-BEFORE-LAB014.txt
VALIDATION-NOTES.txt
REFERENCE.txt
topology.svg / topology.png
configs/r1..r4/lab014-rN-baseline.set
