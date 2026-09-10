vJunos-router bind-directory PoC

Image:
  vrnetlab/juniper_vjunos-router:25.4R1.12

Purpose:
  Keep one vJunos container/VM running and expose multiple Junos config files
  through a host bind mount. Config selection is performed INSIDE Junos CLI.

Topology:
  r1
    host ./configs  ->  container /config/labconfigs (read-only)

Files:
  configs/bootstrap.conf   initial startup config
  configs/lab-001.conf     scenario 1
  configs/lab-002.conf     scenario 2

Deploy:
  containerlab deploy -t vjunos-bind-poc.clab.yml

After the router is ready, from the Junos CLI:

  file list /config/labconfigs

  configure
  load replace /config/labconfigs/lab-001.conf
  show | compare
  commit

Then switch directly to scenario 2:

  configure
  load replace /config/labconfigs/lab-002.conf
  show | compare
  commit

No docker restart, containerlab redeploy, or helper script is required.

NOTE:
  This PoC intentionally uses `load replace` with replace: tags so the
  scenario files replace only the selected configuration hierarchies.
  For a complete scenario image, replace the scenario files with full Junos
  configurations and use `load override /config/labconfigs/<file>` instead.
