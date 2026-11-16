# folderframework-v3 — Swarm / Isolated-Worktree Framework (materialized instance)

Source worktree: `.kilo/worktrees/folderframework-v3` of `eltonaguiar/findtorontoevents_antigravity.ca`
Base commit at creation: `db4cc06ed82`
Created: 2026-11-16 (UTC)

## What this subfolder contains

| Path | Purpose |
|------|---------|
| `2026-11-16-SWARM/` | Dated artifact scaffold implementing the protocol in `/README.MD` (repo root) — charter, TODO/DONE domains, phased review folders, final-plan templates. |
| `tools/swarm/swarm_librarian.py` | Stdlib-only CLI: `scaffold` a dated SWARM folder, `collect` markdown/JSON evidence out of an agent worktree, `index` everything in a SWARM folder. |

The protocol document itself lives at the repository root (`README.MD`) and is the source of truth. This subfolder is one agent-worktree's concrete instantiation: copy `2026-11-16-SWARM/` to the top of the target repo (or keep it here as the shared artifact store) and follow the phases.

## Quick start

```bash
# Regenerate the scaffold for another date / location:
python3 tools/swarm/swarm_librarian.py scaffold --date 2026-11-17 --root .

# Harvest an agent worktree's .md (and small .json evidence) into 03_DONE/DB/:
python3 tools/swarm/swarm_librarian.py collect \
    --src /path/to/wt-db-agent --dest 2026-11-16-SWARM/03_DONE/DB --dry-run

# Rebuild the index after any phase:
python3 tools/swarm/swarm_librarian.py index --dir 2026-11-16-SWARM
```

## Provenance / conflict handling

End results from this worktree are committed directly under `folderframework-v3/` on `main` of this repo. If another agent's subfolder collides, cherry-pick the conflicting commit (per the user's instruction 2026-11-16) rather than force-pushing.
