#!/usr/bin/env python3
"""Create a dated SWARM folder and index markdown. Does not push or delete."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

PHASES = (
    "01_TODO/DB",
    "01_TODO/GHACTIONS",
    "01_TODO/AUDIT",
    "01_TODO/PREDICTION",
    "01_TODO/CROSSCUTTING",
    "02_IN_PROGRESS",
    "03_DONE/DB",
    "03_DONE/GHACTIONS",
    "03_DONE/AUDIT",
    "03_DONE/PREDICTION",
    "04_final_review",
    "05_final_reviewv2",
    "06_final_review3",
    "07_final_review4",
    "99_archive",
    "templates",
    "tools",
)


def init_tree(root: Path) -> None:
    for rel in PHASES:
        path = root / rel
        path.mkdir(parents=True, exist_ok=True)
        marker = path / ".gitkeep"
        if not any(path.iterdir()):
            marker.write_text("", encoding="utf-8")
    print(f"initialized {root}")


def index_md(root: Path, out: Path) -> None:
    lines = ["# INDEX", "", f"Root: `{root}`", ""]
    files = sorted(p for p in root.rglob("*.md") if p.is_file())
    if not files:
        lines.append("No markdown files.")
    for path in files:
        rel = path.relative_to(root)
        lines.append(f"- `{rel}`")
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {out} ({len(files)} files)")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path, help="dated swarm directory")
    parser.add_argument("--init", action="store_true", help="create phase folders")
    parser.add_argument("--index", type=Path, help="write a markdown index to this path")
    args = parser.parse_args(argv)
    if args.init:
        init_tree(args.root)
    if args.index:
        index_md(args.root, args.index)
    if not args.init and not args.index:
        parser.error("pass --init and/or --index")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
