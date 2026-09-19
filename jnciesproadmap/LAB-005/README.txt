JNCIE-SP ROADMAP v1
LAB-005 — POLICY LANGUAGE FUNDAMENTALS

PACKAGE CONTENTS
- LAB-005-TASK.txt
- LAB-005-SOLUTION-GUIDE.txt
- lab005.clab.yml              standalone validation slice
- configs/r1.conf ... r4.conf  Junos startup configuration
- verify.sh                    endpoint-based baseline/final verifier

IMPORTANT
The roadmap version assumes the universal 10-router vJunos physical topology is
already deployed and should not be changed. The included lab005.clab.yml is an
optional standalone validation slice for the policy scenario (R1-R4 + endpoints).
For the universal topology, use the policy/configuration tasks against R1-R4 and
keep the existing physical topology unchanged.

PLATFORM
vJunos-router 25.4R1.12
Credentials: admin / admin@123

Standalone slice management addresses:
R1 172.31.5.11/24
R2 172.31.5.12/24
R3 172.31.5.13/24
R4 172.31.5.14/24
source1 172.31.5.21/24
client1 172.31.5.22/24

DATA-PLANE
source1 -- R1 -- R2 -- R3 -- R4 -- client1

Test prefixes:
10.10.10.0/24       probe 10.10.10.10
10.10.20.0/24       probe 10.10.20.20
10.10.20.128/25     probe 10.10.20.200
10.10.30.128/25     probe 10.10.30.130
10.10.40.0/24       probe 10.10.40.40
10.20.10.0/24       probe 10.20.10.10
