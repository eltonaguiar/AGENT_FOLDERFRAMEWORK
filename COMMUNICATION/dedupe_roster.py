#!/usr/bin/env python3
"""Collapse duplicate seats in a COMS roster.

The roster was append-only, so one swarmbus_id could appear many times: 103 rows
for 35 seats on Linux, 29 for 11 on Windows. Nothing reads history out of this
file, so the repair is to keep the newest row per id, merging non-empty fields,
and leave a timestamped .bak behind.

Dry run by default; pass --apply to write.
"""
import argparse
import collections
import datetime
import json
import pathlib
import shutil


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("path", nargs="?",
                    default=str(pathlib.Path.home() / ".coms" / "agents.jsonl"))
    ap.add_argument("--apply", action="store_true", help="write the collapsed roster")
    a = ap.parse_args()

    p = pathlib.Path(a.path)
    if not p.is_file():
        print("no roster at %s" % p)
        return 2

    rows = []
    for line in p.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            rows.append(json.loads(line))
        except Exception:
            continue

    merged, order = {}, []
    for r in rows:
        k = r.get("swarmbus_id") or "%s|%s" % (r.get("inbox"), r.get("registered_at"))
        if k in merged:
            m = dict(merged[k])
            m.update({k2: v for k2, v in r.items() if v})
            merged[k] = m
        else:
            merged[k] = r
            order.append(k)

    out = [merged[k] for k in order]
    counts = collections.Counter(r.get("swarmbus_id") for r in rows)
    print("rows_before=%d distinct=%d removed=%d" % (len(rows), len(out), len(rows) - len(out)))
    for k, n in counts.most_common(3):
        if n > 1:
            print("  worst %s x%d" % (k, n))

    if not a.apply:
        print("dry run; pass --apply to write (a .bak is kept)")
        return 0

    bak = p.with_suffix(p.suffix + ".bak-" + datetime.datetime.now().strftime("%Y%m%dT%H%M%S"))
    shutil.copy2(p, bak)
    p.write_text("\n".join(json.dumps(r, separators=(",", ":")) for r in out) + "\n",
                 encoding="utf-8")
    print("wrote %s (backup %s)" % (p, bak))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
