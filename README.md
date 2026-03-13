# clabs: Multi-Vendor Network & Security Labs with ContainerLab

[![Python](https://img.shields.io/badge/Python-81%25-blue?logo=python&logoColor=white)](https://github.com/akhmadkun/clabs)
[![Shell](https://img.shields.io/badge/Shell-17.6%25-green?logo=gnu-bash&logoColor=white)](https://github.com/akhmadkun/clabs)
[![Dockerfile](https://img.shields.io/badge/Dockerfile-1.4%25-orange?logo=docker&logoColor=white)](https://github.com/akhmadkun/clabs)
[![ContainerLab](https://img.shields.io/badge/ContainerLab-Modern%20Labs-purple?logo=containerd&logoColor=white)](https://containerlab.dev)
[![Commits](https://img.shields.io/github/commit-activity/y/akhmadkun/clabs?color=brightgreen)](https://github.com/akhmadkun/clabs/commits/main)

Personal **hands-on lab repository** for learning network engineering, security, routing, switching, and automation using **ContainerLab** — the fast, container-based network emulation tool.

This repo covers **multi-vendor environments** (Cisco, Juniper, Arista, Fortinet, Nokia SR Linux, Palo Alto, etc.) with a strong emphasis on:
- Reproducible topologies via YAML
- Python & shell automation scripts
- Real-world scenarios: routing protocols, security policies, HA, AAA, interoperability

> "Build, break, and automate networks in containers — no expensive hardware required."

## Why This Repo Stands Out
- **Multi-vendor coverage**: Labs across Cisco IOS-XE/XR, Juniper, Arista cEOS, Fortinet FortiGate, Nokia SR Linux, Palo Alto PAN-OS, and AAA integrations.
- **Automation-first**: 81% Python code — scripts for config generation, validation, deployment helpers, and more.
- **Active development**: 63+ commits with frequent updates (e.g., recent OSPF lab on Cisco IOS-XE).
- Perfect for:
  - Preparing certifications (Palo Alto NGFW Engineer, CCNP, JNCIP, etc.)
  - Building skills as Network/Security Engineer, Automation Engineer, or Lab Specialist
  - Testing configs quickly in isolated, version-controlled environments

## Key Labs by Vendor

### Cisco
- **ios-xe/**: Routing (OSPF, BGP), switching basics, automation
- **ios-xr/**: XR-specific features, service provider scenarios

### Juniper
- **juniper/**: vMX/vSRX labs, Junos routing & security

### Arista
- **arista/**: cEOS topologies for data center/leaf-spine, EVPN/VXLAN basics

### Fortinet
- **forti/basic-labs/**: FortiGate policies, VPN, basic SD-WAN

### Nokia
- **srlinux/**: Advanced SR Linux routing & segment routing

### Palo Alto Networks
- **panos/**: NGFW basics (zones, multi-arm, client-only setups, testing templates), PAN-OS configs & HA exploration

### Cross-Cutting
- **aaa/**: RADIUS/TACACS+ integrations across vendors
- **template-test/**: Reusable templates & experiments

### Automation Tools
- Python scripts (config push, parsing, validation)
- Shell wrappers for deploy/teardown
- ContainerLab `.clab.yml` files — declarative & easy to share

## Quick Start

1. Install ContainerLab: https://containerlab.dev/install/

2. Clone the repo:
   ```bash
   git clone https://github.com/akhmadkun/clabs.git
   cd clabs

3. Deploy an example lab (e.g., Cisco IOS-XE OSPF):
    ```bash
    cd ios-xe/ospf-lab  # adjust to actual path
    sudo containerlab deploy -t topology.clab.yml

> Note: Pull vendor images first (e.g., via containerlab graph). Check each vendor folder's README or topology for credentials & specifics.

## Portfolio Value

- Demonstrates broad vendor knowledge + deep automation skills.
- Reproducible labs → Ideal for interview demos or team sharing.
- Aligned with modern network practices: IaC mindset, containerized testing.

## Future Plans

- Expand Palo Alto labs (advanced Zero Trust, Panorama API, decryption)
- Add Terraform/Ansible for full IaC
- Multi-vendor interoperability scenarios (e.g., BGP peering across vendors)
- CI/CD pipelines for network changes

Feel free to fork, star, or contribute! Issues/PRs welcome.
Built with ❤️ by Akhmad — Network & Security Enthusiast
