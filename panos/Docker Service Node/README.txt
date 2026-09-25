# Palo Lab Universal Services 1.4

One reusable service image for the Palo Alto expert lab roadmap.

Design:
- image contains software/tools
- each lab owns service configuration under service-config/
- each lab owns test data under service-data/
- container attaches directly to an existing libvirt bridge such as virbr1
- runtime does not require Internet access

Included services:
DNS 53/TCP+UDP
NTP 123/UDP
SSH 22/TCP
HTTP 80/TCP
TFTP 69/UDP
SNMP 161/UDP
Syslog 514/TCP+UDP
RADIUS 1812/1813 UDP
DHCP configuration included, runtime disabled by default

Build once on the host while Internet is available:
    ./build.sh

The default image tag is:
    palo-lab-services:1.4

Example containerlab node:
    server:
      kind: linux
      network-mode: none
      image: palo-lab-services:1.4
      binds:
        - ./service-config:/etc/fnd-services:ro
        - ./service-data/www:/var/www/html:ro
        - ./service-data/tftp:/srv/tftp
      exec:
        - ip link set eth0 up
        - ip addr add 192.168.121.20/24 dev eth0

Existing bridge:
    virbr1 -> 192.168.121.0/24

Host-side verification:
    ./verify.sh
    ./verify.sh <container-name>

No apt-get should be run from inside the isolated service container.

DHCP warning:
    Do not enable DHCP on a libvirt bridge that already runs a DHCP server.
    Use a dedicated lab bridge/subnet and set ALLOW_DHCP=true.
