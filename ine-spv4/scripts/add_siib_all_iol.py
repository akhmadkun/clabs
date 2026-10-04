#!/usr/bin/env python3
"""
Enable IPv4 CEF in all *.cfg files under a lab_configs_iol-style directory.

Usage:
    python3 add_ip_cef_all_iol.py ./lab_configs_iol --dry-run
    python3 add_ip_cef_all_iol.py ./lab_configs_iol
    python3 add_ip_cef_all_iol.py ./lab_configs_iol --no-backup

Behavior:
- Recursively scans all *.cfg files.
- Leaves configs containing `ip cef` unchanged.
- Replaces `no ip cef` with `ip cef`.
- Otherwise inserts `ip cef` in global configuration before the first
  major section (interface/router/line/etc.), or before the final `end`.
- Creates .bak backups by default.
- Safe to run repeatedly (idempotent).
"""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path

GLOBAL_SECTION_START = re.compile(
    r"^(?:interface|router\s+\S+|line\s+\S+|control-plane|policy-map|"
    r"route-map|ip\s+access-list|ipv6\s+access-list|crypto\s+\S+)",
    re.IGNORECASE,
)


def has_global_command(lines: list[str], command: str) -> bool:
    target = command.lower()
    return any(line.strip().lower() == target for line in lines)


def transform_config(text: str) -> tuple[str, bool, str]:
    had_final_newline = text.endswith("\n")
    lines = text.splitlines()

    if has_global_command(lines, "siib"):
        return text, False, "already enabled"

    for i, line in enumerate(lines):
        if line.strip().lower() == "no siib":
            lines[i] = re.sub(
                r"^(\s*)no\s+siib\s*$", r"\1ip cef", line, flags=re.I
            )
            new_text = "\n".join(lines) + ("\n" if had_final_newline else "")
            return new_text, True, "replaced 'no ip cef'"

    insert_at = None
    for i, line in enumerate(lines):
        if line and not line[0].isspace() and GLOBAL_SECTION_START.match(line.strip()):
            insert_at = i
            break

    if insert_at is None:
        for i in range(len(lines) - 1, -1, -1):
            if lines[i].strip().lower() == "end":
                insert_at = i
                break

    if insert_at is None:
        lines.append("ip cef")
    else:
        lines.insert(insert_at, "ip cef")

    new_text = "\n".join(lines) + ("\n" if had_final_newline else "")
    return new_text, True, "added 'ip cef'"


def process_file(path: Path, make_backup: bool, dry_run: bool) -> tuple[bool, str]:
    original = path.read_text(encoding="utf-8", errors="surrogateescape")
    updated, changed, reason = transform_config(original)

    if not changed:
        return False, reason

    if dry_run:
        return True, f"{reason} (dry-run)"

    if make_backup:
        backup = path.with_suffix(path.suffix + ".bak")
        shutil.copy2(path, backup)

    path.write_text(updated, encoding="utf-8", errors="surrogateescape")
    return True, reason


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Enable 'ip cef' in all *.cfg files under a directory."
    )
    parser.add_argument(
        "root",
        nargs="?",
        default="./lab_configs_iol",
        help="Root directory containing R1/R2/... folders",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would change without modifying files.",
    )
    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Do not create .cfg.bak backups.",
    )
    args = parser.parse_args()

    root = Path(args.root).expanduser().resolve()

    if not root.is_dir():
        print(f"ERROR: directory not found: {root}")
        return 1

    cfg_files = sorted(root.rglob("*.cfg"))
    if not cfg_files:
        print(f"No *.cfg files found under: {root}")
        return 0

    changed = 0
    skipped = 0

    print(f"Scanning: {root}")
    print(f"Found {len(cfg_files)} config file(s)\n")

    for path in cfg_files:
        did_change, reason = process_file(
            path,
            make_backup=not args.no_backup,
            dry_run=args.dry_run,
        )
        rel = path.relative_to(root)
        if did_change:
            changed += 1
            print(f"[CHANGE] {rel} -> {reason}")
        else:
            skipped += 1
            print(f"[SKIP]   {rel} -> {reason}")

    print("\nSummary")
    print("-------")
    print(f"Changed : {changed}")
    print(f"Skipped : {skipped}")
    print(f"Total   : {len(cfg_files)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
