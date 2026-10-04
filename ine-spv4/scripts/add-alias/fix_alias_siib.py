#!/usr/bin/env python3
"""
Fix IOS/IOL config placement for:

    alias exec siib show ip int brief | ex una

For every *.cfg under labconfigs/XR*/ or lab_configs_iol/R*/ etc., the
script:

1. Removes every existing exact "siib" alias line.
2. Inserts exactly one alias at a safe global-config location:
   - immediately after a "version ..." line, if present;
   - otherwise after the initial comment/blank header and before the first
     actual configuration command.
3. Creates a .bak backup by default.
4. Is idempotent.

Examples:
    python3 fix_alias_siib.py lab_configs_iol
    python3 fix_alias_siib.py lab_configs_iol --dry-run
    python3 fix_alias_siib.py lab_configs_iol --no-backup

The script recursively processes all *.cfg files below the supplied root.
"""

from __future__ import annotations

import argparse
import re
import shutil
from pathlib import Path

ALIAS = "alias exec siib show ip int brief | ex una"
ALIAS_RE = re.compile(r"^\s*alias\s+exec\s+siib\s+show\s+ip\s+int\s+brief\s+\|\s+ex\s+una\s*$")
VERSION_RE = re.compile(r"^\s*version\s+\S+")


def remove_alias(lines: list[str]) -> list[str]:
    """Remove all existing exact siib alias lines."""
    return [line for line in lines if not ALIAS_RE.match(line.rstrip("\r\n"))]


def insert_alias(lines: list[str]) -> list[str]:
    """
    Insert alias:
      - after version line if present;
      - otherwise before the first non-comment/non-blank line.
    """
    # Prefer the version line if the config has one.
    for idx, line in enumerate(lines):
        if VERSION_RE.match(line.rstrip("\r\n")):
            # Preserve the newline style of the existing file.
            nl = "\r\n" if line.endswith("\r\n") else "\n"
            return lines[:idx + 1] + [ALIAS + nl] + lines[idx + 1:]

    # No version line: skip the leading blank/comment header.
    # Cisco configs commonly have:
    #   ! Last configuration change ...
    #   !
    #   vrf definition ...
    #
    # Insert immediately before the first actual command.
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if stripped and not stripped.startswith("!"):
            nl = "\r\n" if line.endswith("\r\n") else "\n"
            return lines[:idx] + [ALIAS + nl] + lines[idx:]

    # Empty/comment-only file: append the alias.
    nl = "\r\n" if any(line.endswith("\r\n") for line in lines) else "\n"
    return lines + [ALIAS + nl]


def process(path: Path, dry_run: bool, backup: bool) -> str:
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return "SKIP(non-UTF8)"

    original_lines = text.splitlines(keepends=True)

    # Remove any existing copies first, then insert exactly one.
    without_alias = remove_alias(original_lines)
    fixed_lines = insert_alias(without_alias)
    new_text = "".join(fixed_lines)

    if new_text == text:
        return "SKIP(already correct)"

    if dry_run:
        return "WOULD UPDATE"

    if backup:
        backup_path = path.with_suffix(path.suffix + ".bak")
        shutil.copy2(path, backup_path)

    path.write_text(new_text, encoding="utf-8")
    return "UPDATED"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Move/reinsert the IOS/IOL siib alias at a safe global-config location."
    )
    parser.add_argument(
        "root",
        nargs="?",
        default="lab_configs_iol",
        help="Root directory to scan recursively (default: ./lab_configs_iol)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show changes without modifying files",
    )
    parser.add_argument(
        "--no-backup",
        action="store_true",
        help="Do not create *.cfg.bak backups",
    )
    args = parser.parse_args()

    root = Path(args.root).expanduser().resolve()
    if not root.is_dir():
        print(f"ERROR: directory not found: {root}")
        return 1

    cfg_files = sorted(root.rglob("*.cfg"))
    if not cfg_files:
        print(f"ERROR: no *.cfg files found under {root}")
        return 1

    updated = 0
    skipped = 0

    for path in cfg_files:
        result = process(
            path,
            dry_run=args.dry_run,
            backup=not args.no_backup,
        )
        print(f"{path.relative_to(root)}: {result}")

        if result in {"UPDATED", "WOULD UPDATE"}:
            updated += 1
        else:
            skipped += 1

    print("\nSummary")
    print(f"  Config files: {len(cfg_files)}")
    print(f"  Updated/plan: {updated}")
    print(f"  Skipped     : {skipped}")

    if not args.dry_run and not args.no_backup:
        print("  Backup      : *.cfg.bak")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
