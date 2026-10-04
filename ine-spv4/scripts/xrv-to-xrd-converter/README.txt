XRV -> XRd CONFIG CONVERTER
============================

Purpose
-------
Convert an existing Cisco XRv lab config library into an XRd-friendly copy
without touching the original XRV backup.

One script handles all node directories and all *.cfg files.

Example source:
  lab_configs/
    XR1/
      isis.cfg
      ospfv2.cfg
      ...
    XR2/
      ...

Run
---
1) Preview first:

   python3 xrv_to_xrd.py \
     --src ./lab_configs \
     --dst ./lab_configs_xrd \
     --dry-run

2) Convert:

   python3 xrv_to_xrd.py \
     --src ./lab_configs \
     --dst ./lab_configs_xrd \
     --emit-topology ./xrd-mgmt.yml

The script auto-discovers the old XRV management IP from:
  interface MgmtEth0/0/CPU0/0
   ipv4 address X.X.X.X MASK

3) If a node has no management stanza (or more than one address), provide
   a CSV:

   node,ipv4,mask
   XR1,10.200.255.12,255.255.255.0
   XR2,10.200.255.13,255.255.255.0
   XR3,10.200.255.14,255.255.255.0

   Then:

   python3 xrv_to_xrd.py \
     --src ./lab_configs \
     --dst ./lab_configs_xrd \
     --mgmt-map ./mgmt-map.csv \
     --emit-topology ./xrd-mgmt.yml

What gets converted
-------------------
- MgmtEth0/0/CPU0/0 -> MgmtEth0/RP0/CPU0/0
- Removes legacy clab-mgmt VRF block
- Removes the legacy management interface block
- Removes clab-mgmt static route subtree
- Removes management-specific:
    ssh server vrf clab-mgmt
    http client vrf clab-mgmt
    http client source-interface ipv4 MgmtEth0/0/CPU0/0
- Preserves data-plane interfaces and routing/service configuration
- Adds the XRd management interface with the node's static management IP

Important
---------
The output is a converted FILE LIBRARY. It is not a guarantee that every
old XRv feature is supported identically by your XRd image.

For scenario replacement, use a complete XRd-compatible target config if
you intend to use:
  configure
   load <file>
   commit replace

Do not overwrite the XRV backup.

Suggested topology design
-------------------------
Use containerlab static management IPs, for example:

topology:
  nodes:
    XR1:
      kind: cisco_xrd
      mgmt-ipv4: 10.200.255.12
    XR2:
      kind: cisco_xrd
      mgmt-ipv4: 10.200.255.13

The script's --emit-topology option generates this mapping automatically.

Why one script is enough
------------------------
Static management IPs are per-node DATA, not per-node CODE.
The same converter handles all nodes. The only per-node information is
the mapping from node name to management IP, which can usually be auto-
discovered from the existing XRV config.

CSV BOM fix
-----------
The converter accepts UTF-8 CSV files with or without a BOM. Headers are normalized, so files exported by common editors/spreadsheets are supported.
