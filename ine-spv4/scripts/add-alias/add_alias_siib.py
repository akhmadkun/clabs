#!/usr/bin/env python3
"""Add an IOS XR exec alias to every *.cfg under labconfigs/XR*/."""
from __future__ import annotations
import argparse
import shutil
from pathlib import Path

ALIAS = "alias exec siib show ip int brief | ex una"


def process_file(path: Path, backup: bool, dry_run: bool) -> str:
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return "SKIP(binary/non-UTF8)"

    if any(line.strip() == ALIAS for line in text.splitlines()):
        return "SKIP(already present)"

    had_final_newline = text.endswith("\n")
    new_text = ALIAS + "\n"
    if text:
        new_text += text
        if not had_final_newline:
            new_text += "\n"

    if dry_run:
        return "WOULD UPDATE"

    if backup:
        shutil.copy2(path, path.with_suffix(path.suffix + ".bak"))

    path.write_text(new_text, encoding="utf-8")
    return "UPDATED"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Add 'siib' alias to all XR *.cfg files under labconfigs/XR*/."
    )
    parser.add_argument(
        "root", nargs="?", default="labconfigs",
        help="Root labconfigs directory (default: ./labconfigs)",
    )
    parser.add_argument("--dry-run", action="store_true", help="Show changes only")
    parser.add_argument("--no-backup", action="store_true", help="Do not create .bak files")
    args = parser.parse_args()

    root = Path(args.root).expanduser().resolve()
    if not root.is_dir():
        print(f"ERROR: directory not found: {root}")
        return 1

    xr_dirs = sorted(p for p in root.glob("XR*") if p.is_dir())
    if not xr_dirs:
        print(f"ERROR: no XR* directories found under {root}")
        return 1

    total = updated = skipped = 0
    for xr_dir in xr_dirs:
        print(f"\n[{xr_dir.name}]")
        for path in sorted(xr_dir.rglob("*.cfg")):
            total += 1
            result = process_file(path, backup=not args.no_backup, dry_run=args.dry_run)
            print(f"  {path.relative_to(root)}: {result}")
            if result in {"UPDATED", "WOULD UPDATE"}:
                updated += 1
            else:
                skipped += 1

    print("\nSummary")
    print(f"  Files checked : {total}")
    print(f"  To update     : {updated}")
    print(f"  Skipped       : {skipped}")
    if not args.dry_run and updated:
        print("\nDone.")
        if not args.no_backup:
            print("Backups were created as *.cfg.bak")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
