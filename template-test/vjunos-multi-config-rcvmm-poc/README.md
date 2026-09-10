# vJunos multi-config PoC using rc.vmm

This PoC tests the initialization path suggested by Juniper's vMX config-drive
implementation: files are placed under var/db/vmm on the configuration disk,
and var/db/vmm/etc/rc.vmm copies them into normal guest storage at boot.

Build:
  docker build -t local/vrnetlab/juniper_vjunos-router:25.4R1.12-rcvmm .

Deploy once:
  containerlab deploy -t vjunos-multi-config-rcvmm.clab.yml

Inside Junos, verify:
  file list /var/tmp/labconfigs/
  file show /var/log/multi-config-poc.log

Then test:
  configure
  load override /var/tmp/labconfigs/LAB-001.conf
  show | compare
  commit

Switch:
  load override /var/tmp/labconfigs/LAB-002.conf
  show | compare
  commit

No restart or redeploy is needed for switching.

If /var/tmp/labconfigs is absent, the next diagnostic is to inspect whether
this vJunos release actually executes /var/db/vmm/etc/rc.vmm from its config
drive. The rc.vmm mechanism is documented in Juniper's OpenJNPR/vMX tooling,
but that does not by itself prove it is supported by vJunos-router 25.4R1.12.
