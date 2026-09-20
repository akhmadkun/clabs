#!/usr/bin/env python3
"""
Convert Cisco CSR1000v configuration trees to Cisco IOL configuration trees.

Input:
    lab_configs/
      R1/*.cfg
      R2/*.cfg
      ...

Output:
    lab_configs_iol/
      R1/*.cfg
      R2/*.cfg
      ...

The original tree is NEVER modified.

Usage:
    python convert_csr_to_iol.py \
        --src ./lab_configs \
        --dst ./lab_configs_iol \
        --template ./iol-blank.cfg
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

IFACE_MAP = {
    "GigabitEthernet2": "Ethernet0/1",
    "GigabitEthernet3": "Ethernet0/2",
    "GigabitEthernet4": "Ethernet0/3",
    "GigabitEthernet5": "Ethernet0/4",
}

CSR_TOP_BLOCKS = (
    r"^crypto pki trustpoint\b",
    r"^crypto pki certificate chain\b",
    r"^license udi\b",
    r"^call-home\b",
    r"^redundancy\b",
    r"^platform\b",
    r"^subscriber templating\b",
    r"^multilink bundle-name\b",
    r"^diagnostic bootup\b",
    r"^service call-home\b",
    r"^crypto pki\b",
)

BASELINE_TOP = (
    r"^version\b",
    r"^service timestamps\b",
    r"^hostname\b",
    r"^boot-start-marker\b",
    r"^boot-end-marker\b",
    r"^no aaa new-model\b",
    r"^no ip domain lookup\b",
    r"^ip domain name\b",
    r"^ip cef\b",
    r"^login on-success\b",
    r"^ipv6 unicast-routing\b",
    r"^ipv6 cef\b",
    r"^username admin\b",
    r"^memory free low-watermark processor\b",
    r"^spanning-tree mode\b",
    r"^ip forward-protocol nd\b",
    r"^ip http server\b",
    r"^ip http secure-server\b",
    r"^ip ssh bulk-mode\b",
    r"^no logging btrace\b",
)

def normalize_show_run(text: str) -> str:
    lines = []
    for line in text.replace("\r\n", "\n").splitlines():
        if line.startswith("R1#"):
            continue
        if line.startswith("Building configuration"):
            continue
        if re.match(r"^Current configuration\s*:", line):
            continue
        lines.append(line)
    return "\n".join(lines).strip() + "\n"

def drop_block(lines, predicate):
    out, i = [], 0
    while i < len(lines):
        if predicate(lines[i]):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!", "")):
                i += 1
            continue
        out.append(lines[i])
        i += 1
    return out

def drop_interface_blocks(lines, exact_names=None, prefixes=None):
    exact_names = exact_names or set()
    prefixes = prefixes or ()
    out, i = [], 0
    while i < len(lines):
        m = re.match(r"^interface\s+(\S+)", lines[i])
        if m:
            name = m.group(1)
            if name in exact_names or any(name.startswith(p) for p in prefixes):
                i += 1
                while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!", "")):
                    i += 1
                continue
        out.append(lines[i])
        i += 1
    return out

def convert_interface_line(line):
    m = re.match(r"^(\s*)interface\s+GigabitEthernet([2-5])(\S*)\s*$", line)
    if m:
        return f"{m.group(1)}interface Ethernet0/{int(m.group(2))-1}{m.group(3)}"
    return re.sub(r"\bGigabitEthernet1\b", "Ethernet0/0", line)

def clean_source(lines):
    lines = drop_interface_blocks(lines, prefixes=("GigabitEthernet1",))
    lines = drop_block(lines, lambda x: any(re.match(p, x) for p in CSR_TOP_BLOCKS))

    out = []
    i = 0
    while i < len(lines):
        line = lines[i]

        # Drop CSR management VRF; the IOL template owns this.
        if re.match(r"^vrf definition clab-mgmt\b", line):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!", "")):
                i += 1
            continue

        # Drop CSR management routes.
        if re.match(r"^\s*(ip route vrf clab-mgmt|ipv6 route vrf clab-mgmt)\b", line):
            i += 1
            continue

        # Drop CSR-only singleton commands.
        if re.match(r"^\s*(enable password|no ip icmp rate-limit unreachable|platform console|memory free low-watermark processor)\b", line):
            i += 1
            continue

        # Let the IOL template own the common baseline.
        if any(re.match(p, line) for p in BASELINE_TOP):
            i += 1
            continue

        # Template owns these sections.
        if re.match(r"^(control-plane|line con 0|line aux 0|line vty 0 4)\b", line):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!", "")):
                i += 1
            continue

        # CSR-specific service instance block.
        if re.match(r"^\s*service instance \d+ ethernet\b", line):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!", "")):
                i += 1
            continue

        # Keep TFTP source-interface, but remap it to IOL management.
        line = re.sub(r"^ip tftp source-interface GigabitEthernet1\b",
                      "ip tftp source-interface Ethernet0/0", line)
        line = re.sub(r"^ip http client source-interface GigabitEthernet1\b",
                      "ip http client source-interface Ethernet0/0", line)

        if line.strip() == "end":
            i += 1
            continue

        out.append(convert_interface_line(line))
        i += 1

    return out

def process_file(src_file: Path, dst_file: Path, template_text: str, hostname: str):
    source_lines = src_file.read_text(errors="replace").replace("\r\n", "\n").splitlines()
    scenario = clean_source(source_lines)

    base = normalize_show_run(template_text)
    base = re.sub(r"^hostname\s+\S+$", f"hostname {hostname}", base, flags=re.M)
    result = base.rstrip() + "\n!\n"

    # Remove excessive separator runs from the scenario.
    compact = []
    previous_blank = False
    for line in scenario:
        if line.strip() == "!":
            # Keep separators, but avoid huge runs of them.
            if previous_blank:
                continue
            previous_blank = True
            compact.append("!")
        else:
            previous_blank = False
            compact.append(line.rstrip())

    while compact and compact[0].strip() == "!":
        compact.pop(0)

    result += "\n".join(compact).rstrip() + "\n!\nend\n"
    dst_file.parent.mkdir(parents=True, exist_ok=True)
    dst_file.write_text(result)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", default="./lab_configs")
    ap.add_argument("--dst", default="./lab_configs_iol")
    ap.add_argument("--template", default="./iol-blank.cfg")
    args = ap.parse_args()

    src = Path(args.src)
    dst = Path(args.dst)
    template = Path(args.template)

    if not src.is_dir():
        raise SystemExit(f"ERROR: source directory not found: {src}")
    if not template.is_file():
        raise SystemExit(f"ERROR: IOL template not found: {template}")

    template_text = template.read_text(errors="replace")
    converted = 0

    for node_dir in sorted(p for p in src.iterdir() if p.is_dir()):
        for src_file in sorted(node_dir.glob("*.cfg")):
            rel = src_file.relative_to(src)
            dst_file = dst / rel
            process_file(src_file, dst_file, template_text, node_dir.name)
            converted += 1

    print(f"Converted {converted} config files.")
    print(f"Output: {dst.resolve()}")

if __name__ == "__main__":
    main()
