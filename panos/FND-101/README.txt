# LAB-001 FND-101 — Management Plane Baseline

This lab intentionally does NOT include a Dockerfile.

The service node uses the previously validated local image:
    palo-lab-services:1.4

The PA-VM is an external KVM guest connected to the existing libvirt bridge:
    virbr1 / 192.168.121.0/24

Addresses:
    PA-VM MGT   192.168.121.10/24
    Services    192.168.121.20/24
    Gateway     192.168.121.1

Deploy:
    containerlab deploy -t LAB-001_FND-101.clab.yml

Verify:
    ./verify.sh server

No Internet access is required after the universal image has already been built.

Do NOT use `containerlab destroy --cleanup` in a way that removes or disrupts
the libvirt-owned virbr1 bridge. The topology only references the existing bridge.
