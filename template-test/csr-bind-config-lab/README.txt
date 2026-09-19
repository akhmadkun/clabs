CSR1000v - persistent scenario config directory via bind mount + QEMU TFTP

Goal
====
Deploy the CSR1000v topology once. Keep all lab/scenario configs on the host.
Switch scenarios with IOS XE "configure replace". No containerlab destroy/deploy is needed.

Why this works
==============
The containerlab/vrnetlab CSR1000v management network uses QEMU user-mode networking and
its TFTP root is /tftpboot. The host scenario directory is bind-mounted into
/tftpboot/configs. Therefore IOS XE can retrieve any scenario file over TFTP from
10.0.0.2, which is the QEMU management-side host/gateway.

Topology
========
csr1:Gi2 -------- csr2:Gi2

Host files
==========
configs/
  LAB-001/
    csr1.cfg
    csr2.cfg
  LAB-002/
    csr1.cfg
    csr2.cfg

Deploy once
===========
cd csr-bind-config-lab
sudo containerlab deploy -t csr-bind.clab.yml

Verify the bind
===============
./scripts/verify-bind.sh

Switch to LAB-001
=================
On csr1:
  enable
  configure replace tftp://10.0.0.2/configs/LAB-001/csr1.cfg force

On csr2:
  enable
  configure replace tftp://10.0.0.2/configs/LAB-001/csr2.cfg force

Switch to LAB-002
=================
On csr1:
  configure replace tftp://10.0.0.2/configs/LAB-002/csr1.cfg force

On csr2:
  configure replace tftp://10.0.0.2/configs/LAB-002/csr2.cfg force

Important management note
=========================
"configure replace" replaces the running configuration with the supplied configuration.
For real labs, keep the required management baseline (especially GigabitEthernet1 and
management access) in every replacement file, or maintain a dedicated base block that
must remain present. Do not accidentally remove management access.

Persistence
===========
The replacement changes running-config. If the scenario should survive a reboot, save it:
  copy running-config startup-config

The configs directory is live. Editing a file on the host is immediately reflected in the
container's /tftpboot/configs tree; no container restart is needed.

Caveat
======
This relies on the default vrnetlab QEMU user-mode management networking/TFTP path.
If the CSR is run with management passthrough enabled, the QEMU user-mode TFTP server is
not used. Keep the default host-forwarded management mode for this workflow.
