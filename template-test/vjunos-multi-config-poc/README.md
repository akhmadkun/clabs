# vJunos multi-config PoC

Goal:
- Build one custom image FROM vrnetlab/juniper_vjunos-router:25.4R1.12.
- At initial container startup, the modified config-disk builder copies every
  file from the host ./configs directory into the vJunos configuration disk.
- Inside Junos, the files should appear under /config/labconfigs/.
- Switching scenarios is done only with native Junos CLI.

Build:
  docker build -t local/vrnetlab/juniper_vjunos-router:25.4R1.12-multi-config .

Deploy:
  containerlab deploy -t vjunos-multi-config.clab.yml

Inside Junos:
  file list /config/labconfigs/
  configure
  load override /config/labconfigs/LAB-001.conf
  show | compare
  commit

Then:
  load override /config/labconfigs/LAB-002.conf
  show | compare
  commit

No docker restart / containerlab redeploy is used for scenario switching.
