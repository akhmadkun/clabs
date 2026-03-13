# clabs: Hands-On Network & Security Labs with ContainerLab

[![Python](https://img.shields.io/badge/Python-81%25-blue?logo=python&logoColor=white)](https://github.com/akhmadkun/clabs)
[![Shell](https://img.shields.io/badge/Shell-17.6%25-green?logo=gnu-bash&logoColor=white)](https://github.com/akhmadkun/clabs)
[![Dockerfile](https://img.shields.io/badge/Dockerfile-1.4%25-orange?logo=docker&logoColor=white)](https://github.com/akhmadkun/clabs)
[![ContainerLab](https://img.shields.io/badge/ContainerLab-Modern%20Labs-purple?logo=containerd&logoColor=white)](https://containerlab.dev)
[![Commits](https://img.shields.io/github/commit-activity/y/akhmadkun/clabs?color=brightgreen)](https://github.com/akhmadkun/clabs/commits/main)

Personal lab repository for **deep-dive hands-on learning** in network security, firewall engineering, and multi-vendor automation using **ContainerLab** — the lightweight, container-based network emulation tool.

Built as part of my journey to achieve **Palo Alto Networks NGFW Engineer** certification (and beyond). Focus on real-world scenarios: advanced PAN-OS configurations, zero-trust policies, automation scripts, high availability, Panorama integration, and cross-vendor interoperability.

> "Code your network before you deploy it." — That's the philosophy here.

## Why This Repo?
- **NGFW-focused labs** using official Palo Alto container images (vr-pan, PAN-OS 10.x/11.x).
- **Automation-heavy**: Python scripts (pan-os-python library), shell helpers, and ContainerLab YAML topologies for reproducible deployments.
- **Multi-vendor exposure**: Palo Alto + Fortinet + Arista + Juniper + Cisco IOS-XE/XR + Nokia SR Linux — perfect for vendor-agnostic engineers.
- **63+ commits** of consistent, practical experimentation — not just theory.
- Ideal for:
  - Preparing Palo Alto certifications (NGFW Engineer, Network Security Architect, SSE Engineer, etc.)
  - Building portfolio for Security Engineer / Network Engineer / Automation roles
  - Testing configs in isolated, fast-spin-up environments (no hardware needed!)

## Key Labs & Features

### Palo Alto Networks (panos/)
Advanced NGFW labs covering:
- Zone-based security policies
- User-ID, Device-ID, HIP objects for Zero Trust
- Decryption profiles & SSL inbound/outbound
- Threat Prevention, URL Filtering, WildFire integration
- High Availability (Active/Passive & Active/Active)
- Panorama-managed templates & device groups
- API automation with Python (pan-os-python) — bulk policy push, config export/import, monitoring
- Integration with external tools (e.g., syslog, SNMP, external dynamic lists)

### Other Vendors
- **forti/**: Basic FortiGate labs (policies, VPN, SD-WAN basics)
- **arista/**: cEOS routing & switching topologies
- **juniper/**: vMX / vSRX scenarios
- **ios-xe/** & **ios-xr/**: Cisco routing labs
- **srlinux/**: Nokia SR Linux advanced features
- **aaa/**: Authentication/Authorization labs (RADIUS, TACACS+ cross-vendor)

### Automation & Tools
- Python scripts for config generation/validation
- Shell wrappers for quick deploy/teardown
- ContainerLab topology YAML files (`.clab.yml`) — declarative & version-controlled

## Quick Start

1. Install ContainerLab:  
   https://containerlab.dev/install/

2. Clone this repo:
   ```bash
   git clone https://github.com/akhmadkun/clabs.git
   cd clabs
