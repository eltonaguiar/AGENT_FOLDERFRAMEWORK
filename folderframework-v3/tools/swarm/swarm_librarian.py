#!/usr/bin/env python3
"""swarm_librarian.py — tooling for the Swarm / Isolated-Worktree Framework.

Subcommands:
  scaffold   Create a dated SWARM folder structure (idempotent).
  collect    Harvest .md (and small .json evidence) from an agent worktree into
             a SWARM subfolder. Never overwrites; suffixed copies on collision.
  index      Write INDEX.md listing every artifact in a SWARM folder.

Stdlib only. No git mutations: 'collect' copies files, it does not cherry-pick;
cherry-picking across repos stays a deliberate human/librarian action.
"""
from __future__ import annotations

import argparse
import sys
from datetime import datetime, timezone
from pathlib import Path

DOMAIN_DIRS = ["DB", "GHACTIONS", "AUDIT", "PREDICTION", "CROSSCUTTING"]
DONE_DIRS = ["DB", "GHACTIONS", "AUDIT", "PREDICTION"]
SKIP_DIR_NAMES = {".git", "node_modules", "__pycache__", ".next", "dist", "build"}
DEFAULT_MAX_JSON_BYTES = 256 * 1024  # evidence files only; bigger JSON stays out


def _dated_dir(root: Path, date: str) -> Path:
    return root / f"{date}-SWARM"


def cmd_scaffold(args: argparse.Namespace) -> int:
    target = _dated_dir(Path(args.root).resolve(), args.date)
    dirs = (
        ["01_TODO/" + d for d in DOMAIN_DIRS]
        + ["02_IN_PROGRESS"]
        + ["03_DONE/" + d for d in DONE_DIRS]
        + [
            "04_final_review",
            "05_final_reviewv2",
            "06_final_review3",
            "07_final_review4",
            "99_archive",
        ]
    )
    created = 0
    for d in dirs:
        p = target / d
        if not p.exists():
            p.mkdir(parents=True)
            created += 1
    for fname in ["00_CHARTER.md", "README.md"]:
        p = target / fname
        if not p.exists():
            p.write_text(f"# {fname.replace('.md','')} — {args.date} SWARM\n", encoding="utf-8")
            created += 1
    print(f"scaffold: {target} ({created} new entries)")
    return 0


def _iter_artifacts(src: Path, max_json_bytes: int):
    for p in sorted(src.rglob("*")):
        if not p.is_file():
            continue
        if any(part in SKIP_DIR_NAMES for part in p.parts):
            continue
        if p.suffix.lower() == ".md":
            yield p
        elif p.suffix.lower() == ".json" and p.stat().st_size <= max_json_bytes:
            yield p


def _collision_free(dest_dir: Path, name: str) -> Path:
    cand = dest_dir / name
    if not cand.exists():
        return cand
    stem, suffix = cand.stem, cand.suffix
    i = 2
    while True:
        cand = dest_dir / f"{stem}__{i}{suffix}"
        if not cand.exists():
            return cand
        i += 1


def cmd_collect(args: argparse.Namespace) -> int:
    src = Path(args.src).resolve()
    dest = Path(args.dest).resolve()
    if not src.is_dir():
        print(f"collect: src not a directory: {src}", file=sys.stderr)
        return 2
    artifacts = list(_iter_artifacts(src, args.max_json_bytes))
    moves = []
    for p in artifacts:
        try:
            rel = p.relative_to(src)
        except ValueError:
            rel = Path(p.name)
        target = _collision_free(dest, rel.name) if args.flat else dest / rel
        moves.append((p, target))
    for p, target in moves:
        print(f"{'DRY ' if args.dry_run else ''}{p} -> {target}")
    if args.dry_run:
        print(f"collect: dry run, {len(moves)} files")
        return 0
    for p, target in moves:
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(p.read_bytes())
    print(f"collect: copied {len(moves)} files into {dest}")
    return 0


def cmd_index(args: argparse.Namespace) -> int:
    root = Path(args.dir).resolve()
    rows = []
    for p in sorted(root.rglob("*")):
        if not p.is_file() or p.name == "INDEX.md":
            continue
        if p.suffix.lower() not in (".md", ".json"):
            continue
        if any(part in SKIP_DIR_NAMES for part in p.parts):
            continue
        st = p.stat()
        rows.append((
            str(p.relative_to(root)),
            f"{st.st_size:,}",
            datetime.fromtimestamp(st.st_mtime, tz=timezone.utc).strftime("%Y-%m-%d %H:%M UTC"),
        ))
    lines = [
        f"# INDEX — {root.name}",
        f"Generated {datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')} by swarm_librarian.py",
        "",
        "| File | Size (bytes) | Modified |",
        "|------|--------------|----------|",
    ]
    lines += [f"| {r[0]} | {r[1]} | {r[2]} |" for r in rows]
    out = root / "INDEX.md"
    out.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"index: wrote {out} ({len(rows)} artifacts)")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    sp = sub.add_parser("scaffold", help="create dated SWARM folder structure")
    sp.add_argument("--date", default=datetime.now(timezone.utc).strftime("%Y-%m-%d"))
    sp.add_argument("--root", default=".")
    sp.set_defaults(fn=cmd_scaffold)

    cp = sub.add_parser("collect", help="copy .md + small .json evidence out of a worktree")
    cp.add_argument("--src", required=True, help="agent worktree path")
    cp.add_argument("--dest", required=True, help="SWARM subfolder, e.g. 2026-11-16-SWARM/03_DONE/DB")
    cp.add_argument("--flat", action="store_true", help="flatten paths (rename on collision) instead of preserving tree")
    cp.add_argument("--max-json-bytes", type=int, default=DEFAULT_MAX_JSON_BYTES)
    cp.add_argument("--dry-run", action="store_true")
    cp.set_defaults(fn=cmd_collect)

    ip = sub.add_parser("index", help="write INDEX.md for a SWARM folder")
    ip.add_argument("--dir", required=True)
    ip.set_defaults(fn=cmd_index)

    args = ap.parse_args()
    return args.fn(args)


if __name__ == "__main__":
    raise SystemExit(main())
