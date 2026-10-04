# INE SPv4 / CCIE-SP Lab Adaptation

> **Attribution:** This lab is an adaptation of material from **Andrew Ohanian's CCIE SPv5.1 Labs**.

## Original Source

The original CCIE-SP v5.1 lab workbook and repository are:

- **Author:** Andrew Ohanian
- **GitHub:** https://github.com/andrewohanian/ccie-spv5.1-labs
- **Workbook:** https://ccie-sp.gitbook.io/ccie-spv5.1-labs

The upstream workbook explains that the project was created as a personal study workbook and later made public so other engineers could benefit from the exercises. The `ISIS` section specifically states that its labs use the INE SPv4 topology, and the upstream `ine-spv4` workflow uses a Python script to transfer configuration files to the nodes after deployment.

This repository is **not the original project** and is not intended to replace or impersonate it.

## What Has Been Changed Here

This directory was adapted for a local CCIE-SP study environment.

### Platform adaptation

The original topology was modified to use:

- Cisco **XRd (`cisco_xrd`)** instead of Cisco XRv where applicable.
- Cisco **IOL (`cisco_iol`)** instead of CSR1000v where applicable.
- Interface names and platform-specific configuration adjusted for the replacement platforms.

### Configuration-loading adaptation

The original lab workflow transfers startup configurations to running nodes using the upstream Python workflow.

This adaptation instead uses Containerlab bind mounts:

```text
host configuration directory
          |
          v
   Containerlab bind
          |
          v
 node filesystem / labconfigs
```

This means the configuration files are made available directly inside the nodes and can be loaded from there without the original post-deployment config-transfer workflow.

## Attribution / Copyright

The original lab exercises, topology concepts, task material, explanations, and other material derived from the upstream project remain attributed to their original author/source.

**No ownership of the original material is claimed by this repository.**

This repository also does **not** grant a new license, relicense upstream material, or imply endorsement by Andrew Ohanian.

For the original material and its terms of use, please refer to the upstream project:

- https://github.com/andrewohanian/ccie-spv5.1-labs
- https://ccie-sp.gitbook.io/ccie-spv5.1-labs

## Important Note on Redistribution

The upstream GitBook pages reviewed for this adaptation make the workbook publicly available and provide the GitHub repository, but no explicit open-source license statement was identified in the documentation pages reviewed.

Therefore:

- This README is **an attribution notice, not a license grant**.
- Do not assume that the upstream material is licensed for unrestricted redistribution.
- Original or substantially copied upstream lab content should not be relicensed under this repository's license.
- For a public repository, the safest approach is to keep the publicly published material focused on **your own adaptation code, topology changes, scripts, and documentation**, and direct users to the upstream project for the original lab material.
- If broader redistribution of upstream-derived task/configuration content is intended, obtain permission from the original author or verify an applicable license first.

## Purpose

This repository is maintained for **CCIE-SP study and hands-on lab practice**.

The goal of this adaptation is to make the original study exercises practical in a modern local environment while preserving clear attribution to the original source.

## Sources

Original author/project:

> **Andrew Ohanian — CCIE SPv5.1 Labs**

Original repository:
https://github.com/andrewohanian/ccie-spv5.1-labs

Original workbook:
https://ccie-sp.gitbook.io/ccie-spv5.1-labs

This adaptation is independently maintained and is **not affiliated with or endorsed by Andrew Ohanian, INE, or Cisco Systems, Inc.**
