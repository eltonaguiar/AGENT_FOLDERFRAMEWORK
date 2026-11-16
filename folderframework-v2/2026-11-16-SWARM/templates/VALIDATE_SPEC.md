# swarm_librarian `validate` — spec (proposed subcommand)

Purpose: fail fast when the structure is wrong, so later agents cannot drift.

## CLI

```bash
python3 tools/swarm/swarm_librarian.py validate <swarm-path>
python3 tools/swarm/swarm_librarian.py scaffold --date 2026-11-17 --domains DB,GHACTIONS,AUDIT,PREDICTION,FRONTEND
```

## Checks (exit non-zero on any failure)

| Code | Check | Pass condition |
|---|---|---|
| V1 | Required phase folders/files exist | all names in `rules.required_phase_folders` present |
| V2 | Every `03_DONE/**/*.md` has front-matter | `agent, worktree, domain, phase, status, evidence` present |
| V3 | Every `07_final_review4` canonical file exists | all 5 files present in the phase |
| V4 | Every `evidence:` entry resolves | each `path` exists; each `sha` is a real commit or `non-durable` |
| V5 | No file outside the allowed structure | only `.md` (+ tiny JSON) under known folders |
| V6 | Filename pattern | matches `<agent_id>_<topic>.md` (or `.gitkeep`) |
| V7 | No forbidden files committed | none matching `rules.never_commit` |
| V8 | No unresolved contradiction markers | no `<<<<<<<`, `=======`, `>>>>>>>` |
| V9 | Secret scan | no `redact_patterns` matches in any committed file |

## Wiring

- Run V2–V9 as a **pre-commit hook** in each worktree.
- Run V1–V3 in the librarian **before** `collect`/`index`.
- A merge-agent runs the full set on the dated swarm branch before Phase 7 is accepted.

## Why

v2/v3/v4 diverged (v2 used `00_CHARTER/`, v4 dropped the dated root). V1+V5 alone would have
caught both. V2+V4 make the evidence rule mechanical instead of a convention agents forget.