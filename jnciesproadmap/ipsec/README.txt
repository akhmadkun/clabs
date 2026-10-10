IPsec Universal Containerlab Topology
======================================

Download and extract the archive, then run containerlab from this directory.

Deploy:
  containerlab deploy -t ipsec-universal.clab.yml

Host prerequisite:
  - Existing active host bridge br-univ (the user's libvirt bridge).
  - The YAML uses the user's local cSRX/vSRX image names.
  - Each vSRX binds ./configs read-only at /lab-config and starts its own
    Python HTTP server on TCP/8000 in the vrnetlab/QEMU container, following
    the proven PoC pattern. There is no centralized config-server node.

Topology scale:
  - 3 x vSRX 23.2R2.21
  - 2 x cSRX 23.4R1.9
  - 6 x network-multitool endpoints
  - 3 x per-vSRX HTTP servers (TCP/8000 in each isolated QEMU/vrnetlab container)
  - 2 x service placeholders (CA/OCSP and RADIUS)
  - 1 x bridge node referencing host br-univ

vSRX runtime profile loading (run on the matching vSRX CLI):
  Each vSRX serves the shared ./configs bind mount over HTTP/8000.
  Use the proven QEMU/vrnetlab address 10.0.0.2 from the vSRX guest:
    configure
    load replace http://10.0.0.2:8000/profiles/IPSEC-040/vsrx-hub.conf routing-instance mgmt_junos
    show | compare
    commit check
    commit

cSRX:
  Host directory ./configs is mounted read-only at /lab-config.
  Bootstrap configs are provided through Containerlab startup-config.
  Runtime profile example:
    configure
    load replace /lab-config/profiles/IPSEC-020/csrx-a.conf
    show | compare
    commit check
    commit

Bootstrap addresses:
  WAN1/shared underlay:
    vsrx-hub      198.18.0.11/24
    vsrx-spoke1   198.18.0.12/24
    vsrx-spoke2   198.18.0.13/24
    csrx-a        198.18.0.14/24
    csrx-b        198.18.0.15/24
    svc-ca        198.18.0.20/24
    svc-radius    198.18.0.21/24
  Logical WAN2:
    vsrx-hub      198.19.0.11/24 on ge-0/0/3
    vsrx-spoke1   198.19.0.12/24 on ge-0/0/2
    vsrx-spoke2   198.19.0.13/24 on ge-0/0/2
  LAN gateways:
    hub-a    10.10.10.1/24; host 10.10.10.10
    hub-b    10.10.11.1/24; host 10.10.11.10
    spoke1   10.20.10.1/24; host 10.20.10.10
    spoke2   10.30.10.1/24; host 10.30.10.10
    csrx-a   10.40.10.1/24; host 10.40.10.10
    csrx-b   10.50.10.1/24; host 10.50.10.10

Important limitations:
  1. Three vSRX are the minimum practical set for hub + two spokes, ADVPN
     shortcut experiments and scaled-down GroupVPNv2 scenarios. Two cSRX
     nodes cover lightweight static/NAT/overlap/troubleshooting labs.
  2. WAN1 and logical WAN2 share the same host bridge. They use separate
     IP subnets but are NOT physically isolated ISP failure domains. To test
     actual independent ISP failure, connect WAN2 interfaces to a second
     pre-existing Linux bridge and update the three WAN2 links.
  3. svc-ca and svc-radius are network-multitool placeholders, not configured
     CA/OCSP/RADIUS servers. Install/configure those services for labs 010-015
     and 072-073.
  4. Exact IPSEC-071 NCP/Windows reproduction needs a Windows VM/client.
  5. Large GroupVPN scale labs are scaled down; feature support depends on the
     vSRX release and license/image behavior.
  6. The bootstrap configs only establish basic addressing, SSH and zones.
     They are not complete IPsec profiles. Runtime profiles need the relevant
     IKE/IPsec proposals, VPNs, NAT, policies, routing, certificates and AAA.
  7. The cSRX bootstrap configs use encrypted root password for "admin@123".
     Change it before sharing the lab.
  8. Validate first boot and interface mapping on the exact images. Confirm
     each vSRX HTTP server is running (launcher log: /tmp/config-http.log)
     and that the guest can load from http://10.0.0.2:8000/. cSRX
     mandatory statements and startup-config semantics can differ by image build.

Roadmap fit:
  IPSEC-000: design-only.
  IPSEC-010..015: CA/OCSP + RADIUS placeholders and SRX endpoints.
  IPSEC-020..023, 030..031: cSRX pair or vSRX hub/spokes and LAN hosts.
  IPSEC-040..042: vSRX nodes for dynamic routing over st0.
  IPSEC-050..053: vSRX hub/spokes + logical WAN2; cRPD/real ISP routing can
    be added if a specific underlay scenario requires it.
  IPSEC-060..062: scaled-down KS/GM roles on the vSRX set.
  IPSEC-070..073: vSRX + endpoints/services; exact NCP needs Windows.
  IPSEC-080..084: fault injection, traffic tests, packet capture, MTU/MSS.
  IPSEC-100..102: mixed capstones; optional ISP routing/Windows may be needed.
