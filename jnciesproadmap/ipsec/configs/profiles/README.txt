Runtime profile directory
=========================

Add one config per device per lab, e.g.:
  profiles/IPSEC-020/csrx-a.conf
  profiles/IPSEC-020/csrx-b.conf
  profiles/IPSEC-040/vsrx-hub.conf
  profiles/IPSEC-040/vsrx-spoke1.conf
  profiles/IPSEC-040/vsrx-spoke2.conf

cSRX (host directory bind-mounted at /lab-config):
  configure
  load replace /lab-config/profiles/IPSEC-020/csrx-a.conf
  show | compare
  commit check
  commit

vSRX (each vSRX QEMU/vrnetlab container serves its bind-mounted configs):
  configure
  load replace http://10.0.0.2:8000/profiles/IPSEC-040/vsrx-hub.conf routing-instance mgmt_junos
  show | compare
  commit check
  commit

These are profile paths only; actual per-lab IPsec configuration will be
authored separately from the cookbook roadmap.
