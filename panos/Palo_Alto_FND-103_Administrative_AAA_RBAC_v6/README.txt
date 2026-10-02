FND-103 Administrative AAA and RBAC - v6
========================================

Purpose
-------
Build a Palo Alto administrative AAA lab using public, ready-made GNS3 AAA
containers. This version removes the custom RADIUS/TACACS images used in the
previous revision.

Public AAA image
----------------
  adosztal/aaa:latest

The public image provides both RADIUS and TACACS+ services and comes with
preconfigured lab users. GNS3 lists the appliance as a stable AAA appliance.

Lab addressing
--------------
  PA-VM MGT     192.168.122.10/24
  RADIUS        192.168.122.20/24
  TACACS+       192.168.122.21/24
  AA test host  192.168.122.30/24
  Gateway       192.168.122.1

RADIUS
------
  Server       192.168.122.20/UDP 1812
  Client       PA-VM 192.168.122.10
  Shared secret: gns3
  User        : alice
  Password     gns3

TACACS+
-------
  Server        192.168.122.21/TCP 49
  Client        PA-VM 192.168.122.10
  Shared secret: gns3
  User          gns3 / Password gns3   (admin test user)
  User          readonly / Password gns3 (read-only test user)

Important
---------
This lab assumes the PA-VM management interface is already reachable on the
existing libvirt virbr0 network. The topology intentionally does not create,
modify, or delete virbr0 or virbr1-virbr6.

The AAA containers use their own Containerlab management interface plus an
additional eth1 connected to the existing virbr0 bridge. The eth1 address is
configured with ifconfig inside the public AAA image.

Do NOT run the old v3/v4/v5 topology against this package. Use only
fnd103-aaa.clab.yml from this directory.
