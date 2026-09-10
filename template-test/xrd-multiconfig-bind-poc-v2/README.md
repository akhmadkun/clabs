# XRd multi-config bind PoC v2

Image:
  sbezverk/xrd-control-plane:25.2.1

This version uses the official containerlab XRd default startup template
structure so the `clab` user and SSH/NETCONF management remain available.

Deploy:
  containerlab deploy -t xrd-multiconfig-bind-v2.clab.yml

Expected SSH:
  ssh clab@<management-ip>
  password: clab@123

Verify the host-side bind:
  docker exec -it clab-xrd_multiconfig_bind_v2-xr1     ls -la /xr-storage/labconfigs

Expected:
  LAB-001.cfg
  LAB-002.cfg
  LAB-003.cfg

Then from XR CLI:
  show filesystem
  dir disk0:
  dir harddisk:

The key point to determine is how /xr-storage is exposed through the XR
filesystem aliases in this XRd release. Once found, test native IOS XR
configuration loading from that path.

The official containerlab XRd documentation says:
- `/xr-storage` is mounted from the node lab directory and persists state.
- If a custom startup-config is supplied, use the default XRd template as the
  base and add commands without removing the template's management setup.
