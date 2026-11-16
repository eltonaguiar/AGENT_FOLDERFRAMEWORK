#!/usr/bin/env python3
"""Pull the framework repo and print pending mentions. Does not launch agents or push."""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


def pending(path: Path) -> bool:
    text = path.read_text(encoding="utf-8", errors="replace")
    return "status: pending" in text.lower() or "status:pending" in text.lower()


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--role", action="append", default=[], help="role file stem, e.g. librarian or @all")
    parser.add_argument("--pull", action="store_true", help="git pull --ff-only before reading")
    args = parser.parse_args(argv)
    repo = args.repo
    if args.pull:
        subprocess.run(["git", "pull", "--ff-only"], cwd=repo, check=False)
    mentions = repo / "COMMUNICATION" / "mentions"
    if not mentions.is_dir():
        print(f"no mentions dir: {mentions}", file=sys.stderr)
        return 1
    stems = {r.lstrip("@") for r in args.role} or None
    found = 0
    for path in sorted(mentions.glob("@*.md")):
        stem = path.stem.lstrip("@")
        if stems is not None and stem not in stems and path.stem not in args.role:
            continue
        if pending(path):
            found += 1
            print(f"PENDING {path.relative_to(repo)}")
            print(path.read_text(encoding="utf-8", errors="replace"))
    if found == 0:
        print("no pending mentions")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
