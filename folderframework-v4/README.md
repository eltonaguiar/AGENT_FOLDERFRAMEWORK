# folderframework-v4 — GH Actions Audit Deliverable

Durable end result of the `folderframework-v4` worktree, deposited here per the swarm
framework in the repo root (`../README.MD`). This subfolder is namespaced to avoid collisions
with other agents' folders; if a merge conflict ever arises, this work is cherry-picked onto `main`.

## Layout

```
folderframework-v4/
├── README.md                     ← this file (index)
├── 00_CHARTER.md                 ← scope, success criteria, roster
├── 03_DONE/
│   └── GHACTIONS/
│       ├── 2026-11-15_21-00-33_EST_ghactions/   ← Phase-1 analysis (8 files)
│       │   ├── branch_capability.tsv
│       │   ├── branch_prune_list.md
│       │   ├── branch_trigger_audit.md
│       │   ├── cron_stagger_plan.md
│       │   ├── cron_verification.md
│       │   ├── orphan_items.md
│       │   ├── push_chain_impact.md
│       │   └── site_impact_audit.md
│       └── 2026-11-16_02-07_EST_ghactions/      ← runbook + coordinator TODOs
│           ├── revert_runbook.md
│           └── TODOS.md
└── 07_final_review4/             ← Phase-5 canonical outputs
    ├── PLAN.md
    ├── IMPLEMENTATION_STEPS.md
    ├── TESTING_PLAN.md
    ├── FILES_TO_TOUCH.md
    └── EVIDENCE_INDEX.md
```

## TL;DR

- **No push-trigger hazard exists on `origin/main`** (0 of 358 workflows with neither `branches:` nor `paths:`). An earlier "4 whole-fleet-on-push hazards" claim is **retracted**.
- **The real push risk is a stale-fork trap:** this working tree is 88367 ahead / 15 behind `origin/main`; a naive `git add .github/workflows/` would revert a live 90→60 timeout fix and resurrect 9 deleted files. Stage docs only, file by file.
- **Cron minute-0 concentration:** 52.5 % of cron lines fire at minute 0. A deterministic `crc32 % 60` stagger spreads them with no semantic change.
- **`/audit` impact of the 12-file delta: none** — no resurrected deletion writes the live `/audit` directory. The one genuine residual risk is `deploy-competition-to-site.yml` (no concurrency group, `/audit` in its push paths), which is *outside* the 12-file delta.
- **Orphans:** the DB-freshness committer is manual-only while the guardian is artifact-only (committed `db_freshness.json` can only age); sports workflows may be frozen-but-plausible (no git-visible disable).

See `07_final_review4/PLAN.md` for the full synthesis and `EVIDENCE_INDEX.md` for claim→evidence links.