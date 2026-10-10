LAB-001 - SINGLE OSPF DOMAIN, MULTI-AREA (cRPD)

IMAGE
  xzjt/crpd:25.2R1-S1.4

FILES
  lab-001.clab.yml     Containerlab topology
  configs/r1.conf      R1 startup config - addressing only
  configs/r2.conf      R2 startup config - addressing only
  configs/r3.conf      R3 startup config - addressing only
  configs/r4.conf      R4 startup config - addressing only
  TASK.txt             Task-only worksheet
  SOLUTION-GUIDE.txt   Step-by-step solution for junior engineers
  ADDRESS-PLAN.txt     Interface and prefix reference
  deploy.sh            Deploy the topology
  configure-hosts.sh   Address the three Linux endpoints and add return routes toward the routers
  verify.sh            Display useful cRPD verification output
  destroy.sh           Remove the topology

REQUIREMENTS
- Containerlab installed on the host.
- Docker available to the user running Containerlab.
- The image xzjt/crpd:25.2R1-S1.4 already available locally or pullable from its registry.
- The endpoint image ghcr.io/srl-labs/network-multitool:latest available locally or pullable.

START
  ./deploy.sh
  ./configure-hosts.sh
  Read TASK.txt before using SOLUTION-GUIDE.txt.

The cRPD startup-config files intentionally contain interface addressing only.
They do not configure routing-options router-id or protocols ospf. OSPF is the
skill being practiced in this exercise.

Containerlab official documentation:
https://containerlab.dev/manual/kinds/crpd/
https://containerlab.dev/manual/topo-def-file/
https://containerlab.dev/manual/config-mgmt/

Juniper official cRPD OSPF example:
https://www.juniper.net/documentation/us/en/software/crpd/crpd-deployment/topics/task/configure-settings-on-crpd.html
