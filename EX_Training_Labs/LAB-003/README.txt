============================================================
JUNIPER EX SERIES OPERATIONS & TROUBLESHOOTING
LAB-003 — RSTP & LAYER-2 LOOP PREVENTION
============================================================

PURPOSE
Practical RSTP operations and troubleshooting on Juniper
EX-style switching.

IMAGE
vrnetlab/juniper_vjunos-switch:25.4R1.12

TOPOLOGY
Three switches form a Layer-2 triangle.
Host1 is attached to SW1.
Host2 is attached to SW3.
All switch-to-switch links carry VLAN 10 / USERS.

FILES
  clab.yml
  TASK-ONLY.txt
  SOLUTION-GUIDE.txt
  README.txt
  configs/
    sw1.conf
    sw2.conf
    sw3.conf
  scripts/
    verify.sh

DEPLOY
  containerlab deploy -t clab.yml

VERIFY
  ./scripts/verify.sh

DESTROY
  containerlab destroy -t clab.yml

NOTE
The Solution Guide includes each task together with its complete
solution, verification, expected result, explanation, and
junior-engineer notes.
