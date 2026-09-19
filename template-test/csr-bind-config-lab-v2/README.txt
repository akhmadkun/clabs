CSR1000v persistent scenario-config lab (Approach A)
======================================================

Goal
----
Deploy the CSR1000v topology once. Keep ALL scenario configs on the host in one
bind-mounted directory. Switch between LAB-001, LAB-002, etc. with IOS XE
"configure replace". No containerlab destroy/deploy is required between labs.

Current image
-------------
arthurk99/cisco-csr1000v

Bind design
-----------
Host:
  ./configs

Container:
  /tftpboot/configs

QEMU TFTP:
  10.0.0.2 -> /tftpboot

Therefore IOS XE can fetch:
  tftp://10.0.0.2/configs/LAB-001/csr1.cfg
  tftp://10.0.0.2/configs/LAB-002/csr1.cfg

Why the previous files failed
------------------------------
The earlier PoC files were partial snippets. Cisco documents that
"configure replace" requires a COMPLETE Cisco IOS XE configuration file (or an
external file that follows the format of a generated IOS XE configuration).
A partial config is appropriate for "copy <source> running-config", but not for
"configure replace".

These revised scenario files include:
  - version header
  - global configuration
  - clab-mgmt VRF
  - GigabitEthernet1 management interface
  - ip tftp source-interface GigabitEthernet1
  - local admin user / SSH
  - GigabitEthernet2 lab interface
  - Loopback100 scenario identifier
  - terminal "end"

Important
---------
The scenario configs are a self-contained LAB PoC. For your real JNCIE/CCIE
labs, the safest pattern is to keep the required management baseline in EVERY
scenario file and then put the full lab-specific configuration around it.

Do not accidentally omit management access from a replacement file.

Deploy once
-----------
sudo containerlab deploy -t csr-bind.clab.yml

Verify bind
-----------
./scripts/verify-bind.sh

Validate file structure
-----------------------
./scripts/check-config-format.sh

Load LAB-001
------------
On CSR1:
  configure replace tftp://10.0.0.2/configs/LAB-001/csr1.cfg force
On CSR2:
  configure replace tftp://10.0.0.2/configs/LAB-001/csr2.cfg force

Load LAB-002 (same running containers)
---------------------------------------
On CSR1:
  configure replace tftp://10.0.0.2/configs/LAB-002/csr1.cfg force
On CSR2:
  configure replace tftp://10.0.0.2/configs/LAB-002/csr2.cfg force

The host directory is live
---------------------------
Edit/add scenario files on the host while containers are running. Because the
host directory is bind-mounted into /tftpboot/configs, the next TFTP GET sees
the updated file without a container restart.

Management VRF note
-------------------
Gi1 is in VRF clab-mgmt. Keep:
  ip tftp source-interface GigabitEthernet1

The TFTP path is reachable over the QEMU user-mode management network. The image's
QEMU process shows:
  -netdev user,...,net=10.0.0.0/24,tftp=/tftpboot,...

The CSR guest uses 10.0.0.15/24 on Gi1 in this PoC, while 10.0.0.2 is the
QEMU-side endpoint that provides the TFTP root.

Scenario naming recommendation
-------------------------------
Use:
  configs/LAB-001/<node>.cfg
  configs/LAB-002/<node>.cfg
  configs/LAB-003/<node>.cfg

Keep the physical topology stable. Only replace the per-node full configs.

Official behavior reference
----------------------------
Cisco: configure replace requires a complete IOS/IOS XE configuration file and
computes the necessary additions/deletions against the current running config.
See the Cisco Configuration Replace / Rollback documentation.
