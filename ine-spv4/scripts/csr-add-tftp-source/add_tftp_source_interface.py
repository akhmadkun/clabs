#!/usr/bin/env python3
"""
add_tftp_source_interface.py

Add the Cisco IOS/IOS XE configuration:

    ip tftp source-interface GigabitEthernet1

to every *.cfg file under node directories such as:

    lab_configs/
    ├── R1/
    ├── R2/
    └── ...

The script is idempotent: if the command already exists, it will not add
another copy.

IMPORTANT:
For a config-replace/startup configuration file, do NOT add:
    conf t
The file should contain the actual configuration command:
    ip tftp source-interface GigabitEthernet1
"""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path

CONFIG_LINE = "ip tftp source-interface GigabitEthernet1"


def has_config(lines: list[str]) -> bool:
    target = CONFIG_LINE.lower()
    return any(line.strip().lower() == target for line in lines)


def add_config(path: Path, backup: bool, dry_run: bool) -> str:
    text = path.read_text(encoding="utf-8", errors="replace")
    had_final_newline = text.endswith("\n")
    lines = text.splitlines()

    if has_config(lines):
        return "SKIP"

    if dry_run:
        return "ADD"

    if backup:
        backup_path = path.with_suffix(path.suffix + ".bak")
        shutil.copy2(path, backup_path)

    # Insert before the final "end" when present.
    end_index = None
    for i in range(len(lines) - 1, -1, -1):
        if lines[i].strip().lower() == "end":
            end_index = i
            break

    if end_index is not None:
        # Keep a normal IOS config separator before the command.
        insert = []
        if end_index > 0 and lines[end_index - 1].strip() != "!":
            insert.append("!")
        insert.append(CONFIG_LINE)
        insert.append("!")
        lines[end_index:end_index] = insert
    else:
        if lines and lines[-1].strip() != "!":
            lines.append("!")
        lines.append(CONFIG_LINE)
        lines.append("!")
        lines.append("end")

    output = "\n".join(lines)
    if had_final_newline or output:
        output += "\n"

    path.write_text(output, encoding="utf-8")
    return "ADD"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Add 'ip tftp source-interface GigabitEthernet1' to all .cfg files."
    )
    parser.add_argument(
        "--root",
        type=Path,
        default=Path("./lab_configs"),
        help="Root config directory (default: ./lab_configs)",
    )
    parser.add_argument(
        "--backup",
        action="store_true",
        help="Create .bak backup files before modifying configs",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show which files would be modified without changing them",
    )
    args = parser.parse_args()

    if not args.root.is_dir():
        print(f"ERROR: directory not found: {args.root}")
        return 1

    files = sorted(args.root.rglob("*.cfg"))

    if not files:
        print(f"No *.cfg files found under {args.root}")
        return 0

    added = 0
    skipped = 0

    for path in files:
        result = add_config(path, backup=args.backup, dry_run=args.dry_run)
        if result == "ADD":
            print(f"[ADD ] {path}")
            added += 1
        else:
            print(f"[SKIP] {path} (already present)")
            skipped += 1

    action = "would be modified" if args.dry_run else "modified"
    print(f"\nDone: {added} file(s) {action}, {skipped} file(s) skipped.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
