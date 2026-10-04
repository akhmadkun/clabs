#!/usr/bin/env python3
"""
xrv_to_xrd.py

Convert a tree of Cisco XRv/IOS XR config files to Cisco XRd-friendly configs.

Design:
- One script processes every node directory and every *.cfg file.
- Management IP is auto-discovered from legacy:
      interface MgmtEth0/0/CPU0/0
       ipv4 address A.B.C.D MASK
- Optional CSV map can override/define management IPs.
- Legacy clab-mgmt management VRF/config is removed.
- Management interface is converted to:
      MgmtEth0/RP0/CPU0/0
  with the same IP address.
- Data-plane interfaces and routing/service configuration are otherwise
  preserved.
- Output is written to a separate tree, so the XRV backup remains untouched.

This script intentionally does NOT modify the original files.
"""

from __future__ import annotations

import argparse
import csv
import ipaddress
import re
import shutil
import sys
from pathlib import Path


MGMT_OLD = "MgmtEth0/0/CPU0/0"
MGMT_NEW = "MgmtEth0/RP0/CPU0/0"


def parse_mgmt_map(path: Path) -> dict[str, tuple[str, str]]:
    """Read CSV: node,ipv4,prefix_or_mask"""
    result: dict[str, tuple[str, str]] = {}
    if not path:
        return result

    with path.open(newline="", encoding="utf-8-sig") as fh:
        reader = csv.DictReader(fh)
        # Normalize UTF-8 BOM/whitespace in headers from editors/spreadsheets.
        if reader.fieldnames:
            reader.fieldnames = [h.strip().lstrip("\ufeff") if h else h for h in reader.fieldnames]
        required = {"node", "ipv4"}
        missing = required - set(reader.fieldnames or [])
        if missing:
            raise ValueError(f"{path}: missing CSV header(s): {", ".join(sorted(missing))}. Expected: node,ipv4,mask")
        for row in reader:
            node = row["node"].strip()
            raw = row["ipv4"].strip()
            # Accept either:
            #   10.200.255.12,255.255.255.0
            # or:
            #   10.200.255.12/24,
            if "/" in raw:
                iface = ipaddress.ip_interface(raw)
                result[node] = (str(iface.ip), str(iface.network.netmask))
            else:
                mask = row.get("mask", "").strip()
                if not mask:
                    raise ValueError(
                        f"{path}: node {node}: provide 'mask' when ipv4 has no prefix"
                    )
                result[node] = (raw, mask)
    return result


def discover_mgmt_ips(node_dir: Path) -> set[tuple[str, str]]:
    """Scan all cfgs in a node dir for legacy management address."""
    found: set[tuple[str, str]] = set()
    pattern = re.compile(
        r"^interface\s+" + re.escape(MGMT_OLD) + r"\s*$"
    )
    ip_pattern = re.compile(
        r"^\s+ipv4\s+address\s+(\S+)\s+(\S+)\s*$"
    )

    for cfg in sorted(node_dir.glob("*.cfg")):
        lines = cfg.read_text(encoding="utf-8", errors="replace").splitlines()
        in_mgmt = False
        for line in lines:
            if pattern.match(line):
                in_mgmt = True
                continue
            if in_mgmt and line and not line.startswith(" "):
                in_mgmt = False
            if in_mgmt:
                m = ip_pattern.match(line)
                if m:
                    found.add((m.group(1), m.group(2)))
    return found


def top_level_blocks(lines: list[str]) -> list[list[str]]:
    """
    Split IOS XR config into top-level blocks.
    A top-level command starts with no leading whitespace.
    Standalone '!' lines are separators.
    """
    blocks: list[list[str]] = []
    current: list[str] = []

    for line in lines:
        if line.strip() == "":
            # Preserve blank lines inside current block.
            if current:
                current.append(line)
            continue

        if line == "!":
            if current:
                blocks.append(current)
                current = []
            continue

        is_top = not line.startswith(" ")
        if is_top and current:
            blocks.append(current)
            current = []

        current.append(line)

    if current:
        blocks.append(current)

    return blocks


def remove_nested_vrf(block: list[str], vrf_name: str) -> list[str]:
    """
    In a top-level 'router static' block, remove only:
        vrf <vrf_name>
    and its nested children.
    """
    out: list[str] = []
    i = 0

    while i < len(block):
        line = block[i]
        if line.startswith(f" vrf {vrf_name}"):
            i += 1
            # Skip until another sibling at indent 1 or end of block.
            while i < len(block):
                nxt = block[i]
                if nxt.startswith(" vrf ") and not nxt.startswith("  "):
                    break
                i += 1
            continue

        out.append(line)
        i += 1

    return out


def normalize_block(block: list[str], mgmt_ip: str, mgmt_mask: str) -> list[list[str]]:
    """Return zero or more converted blocks."""
    if not block:
        return []

    first = block[0].strip()

    # Drop old file preamble comments.
    if first.startswith("!! IOS XR Configuration"):
        return []

    # Remove legacy management VRF entirely.
    if first == "vrf clab-mgmt":
        return []

    # Remove old management interface; we'll add XRd's interface later.
    if first == f"interface {MGMT_OLD}":
        return []

    # Remove management-only commands tied to legacy clab-mgmt.
    if first in {
        "ssh server vrf clab-mgmt",
        "http client vrf clab-mgmt",
        f"http client source-interface ipv4 {MGMT_OLD}",
    }:
        return []

    if first == "router static":
        block = remove_nested_vrf(block, "clab-mgmt")
        # If nothing useful remains, drop the whole block.
        meaningful = [x for x in block[1:] if x.strip()]
        if not meaningful:
            return []
        return [block]

    # Replace any residual old management interface reference in commands.
    converted = [
        line.replace(MGMT_OLD, MGMT_NEW)
        for line in block
    ]
    return [converted]


def convert_file(
    src: Path,
    dst: Path,
    mgmt_ip: str,
    mgmt_mask: str,
    overwrite: bool = False,
) -> None:
    text = src.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()

    converted_blocks: list[list[str]] = []
    for block in top_level_blocks(lines):
        converted_blocks.extend(normalize_block(block, mgmt_ip, mgmt_mask))

    # Remove an old terminal 'end' from any block so we can re-add it once.
    cleaned: list[str] = []
    for block in converted_blocks:
        while block and block[-1].strip() == "end":
            block = block[:-1]
        if block:
            cleaned.extend(block)
            cleaned.append("!")

    # Add XRd management interface with the static address.
    cleaned.extend([
        f"interface {MGMT_NEW}",
        f" ipv4 address {mgmt_ip} {mgmt_mask}",
        " no shutdown",
        "!",
        "end",
    ])

    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists() and not overwrite:
        raise FileExistsError(f"Refusing to overwrite: {dst}")
    dst.write_text("\n".join(cleaned) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Convert Cisco XRv config trees into XRd-friendly config trees."
    )
    ap.add_argument("--src", type=Path, required=True,
                    help="Source root containing node directories, e.g. lab_configs")
    ap.add_argument("--dst", type=Path, required=True,
                    help="Destination root, e.g. lab_configs_xrd")
    ap.add_argument("--mgmt-map", type=Path,
                    help="Optional CSV with node,ipv4,mask. Overrides auto-discovery.")
    ap.add_argument("--overwrite", action="store_true",
                    help="Overwrite files already present in destination.")
    ap.add_argument("--dry-run", action="store_true",
                    help="Show what would be converted without writing files.")
    ap.add_argument("--emit-topology", type=Path,
                    help="Write a containerlab YAML node snippet using discovered mgmt IPs.")
    args = ap.parse_args()

    if not args.src.is_dir():
        print(f"ERROR: source directory not found: {args.src}", file=sys.stderr)
        return 2

    try:
        mgmt_map = parse_mgmt_map(args.mgmt_map) if args.mgmt_map else {}
    except Exception as exc:
        print(f"ERROR reading mgmt map: {exc}", file=sys.stderr)
        return 2

    node_dirs = sorted(p for p in args.src.iterdir() if p.is_dir())
    if not node_dirs:
        print(f"ERROR: no node directories found under {args.src}", file=sys.stderr)
        return 2

    discovered: dict[str, tuple[str, str]] = {}
    errors = 0

    for node_dir in node_dirs:
        node = node_dir.name
        if node in mgmt_map:
            ip_mask = mgmt_map[node]
        else:
            found = discover_mgmt_ips(node_dir)
            if len(found) == 0:
                print(f"ERROR: {node}: no legacy MgmtEth address found; "
                      f"use --mgmt-map", file=sys.stderr)
                errors += 1
                continue
            if len(found) > 1:
                print(f"ERROR: {node}: multiple management IPs found: {sorted(found)}; "
                      f"use --mgmt-map", file=sys.stderr)
                errors += 1
                continue
            ip_mask = next(iter(found))

        discovered[node] = ip_mask

    if errors:
        return 3

    if args.emit_topology:
        lines = ["topology:", "  nodes:"]
        for node, (ip, mask) in discovered.items():
            lines += [
                f"    {node}:",
                "      kind: cisco_xrd",
                f"      mgmt-ipv4: {ip}",
            ]
        args.emit_topology.parent.mkdir(parents=True, exist_ok=True)
        args.emit_topology.write_text("\n".join(lines) + "\n", encoding="utf-8")

    for node_dir in node_dirs:
        node = node_dir.name
        mgmt_ip, mgmt_mask = discovered[node]

        for src in sorted(node_dir.glob("*.cfg")):
            rel = src.relative_to(args.src)
            dst = args.dst / rel

            if args.dry_run:
                print(f"[DRY] {src} -> {dst}  mgmt={mgmt_ip}/{mgmt_mask}")
                continue

            try:
                convert_file(
                    src, dst, mgmt_ip, mgmt_mask, overwrite=args.overwrite
                )
                print(f"[OK]  {rel}  mgmt={mgmt_ip} {mgmt_mask}")
            except Exception as exc:
                print(f"[FAIL] {rel}: {exc}", file=sys.stderr)
                return 4

    if not args.dry_run:
        print(f"\nDone. XRd configs written to: {args.dst}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
