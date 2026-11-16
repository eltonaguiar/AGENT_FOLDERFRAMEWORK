# 10 — Errata & handoff (folderframework-v4)

**Date:** 2026-11-16
**Basis:** fresh `git fetch origin main` at **origin/main `72bcaaf629a`** (FTE) and **`a17644c`** (AFF).
**Purpose:** correct the internal inconsistencies flagged by `folderframework-v3/v2/01_PEER_CROSS_REVIEW.md`, and hand off cleanly.

> Every number below is re-derived at the SHA above. The originals in `03_DONE/GHACTIONS/` were pinned to older, non-durable SHAs (`ae3f4dc`, `5e86dd1`, `eb23252`) and some were internally inconsistent. This file supersedes those counts.

---

## 1. Corrections (errata)

| # | Original claim (v4) | Problem | Corrected (this SHA) |
|---|---|---|---|
| E1 | "356 workflow files @ `ae3f4dc`" / "358" / "373" in different places | three different denominators | **375** files in `.github/workflows/` on origin/main; **373** on this branch's HEAD (2 behind) |
| E2 | "12-file delta (9 D + 1 M + 2 R)" | stale; main has moved far past it | **Now:** 2 files only in origin/main not in HEAD — `gha-health-audit.yml` (A), `gha-queue-audit.yml` (A), `torontoevent-backtest-and-deploy-ROOCODE.yml.disabled` (R100). Everything else is line-drift, not add/delete. |
| E3 | "minute-0 189/360" vs "190/362" | two different totals | **189/360 (52.5 %)** — use 360 cron lines as the denominator (362 included 2 non-cron matches) |
| E4 | "ahead 88367 / behind 15" | stale snapshot | **ahead 0 / behind 2356** (this branch `folderframework-v4` vs origin/main) — the branch has no unique commits; it is purely behind |
| E5 | "`deploy-fte-index.yml` writes `/audit`" vs "no-write" in different docs | contradiction | **No `/audit` write.** `deploy-fte-index.yml` is `paths:`-filtered on `TORONTOEVENTS_ANTIGRAVITY/index.html` + `next_htaccess`; it does not touch `/audit/`. Only `deploy-competition-to-site.yml` has `/audit` in its push paths. |
| E6 | "guardian never commits" vs "writes same path" | contradiction | **Guardian uploads an artifact, does not `git commit`.** `db-freshness-guardian.yml` on origin/main uses `actions/upload-artifact@v6` (path `audit_dashboard/data/db_freshness.json`); there is no `git add/commit/push` step. It **writes the same path** as an artifact, but never commits it to git. |
| E7 | "Step 7-A1: archive `db-freshness-check.yml`" | file no longer exists | **`db-freshness-check.yml` is gone from origin/main** (only `db-freshness-guardian.yml` remains). O2 — obsolete, nothing to archive. |
| E8 | "Step 9: add concurrency to `deploy-competition-to-site.yml`" | already landed | **Landed** as `20f6e1cdad1`. O1 — obsolete, keep as regression watch only. |
| E9 | "branch population 213" vs "215" | minor | not re-derived; not load-bearing for any conclusion — dropped |
| E10 | `4645d08eee4` used as restore SHA (3 refs) | local-only, unrunnable elsewhere | **Purge.** Restore against **`origin/main`** (blob `d2ec26fef7…`) or `2a8421d197e`. Never `4645d08eee4`. |
| E11 | Evidence in volatile `/tmp/qa3/*` | not reproducible | see §3 — reproducible commands instead |

## 2. What still holds (unchanged conclusions)

- **No push-trigger hazard on main** (0 of 375 workflows with neither `branches:` nor `paths:` under `push:`). The earlier "4 whole-fleet hazards" and "235 stale workflows" remain **retracted**.
- **`dynamic-alpha-engine.yml` must stay `timeout-minutes: 90`** — origin/main line 119 has `90`; HEAD line 115 also has `90`. **No regression in this branch.** (The 90→60 regression risk is only if someone stages a stale blob.)
- **Stale-fork push trap is real but the direction is "behind only."** This branch has 0 unique commits; it cannot revert anything by being pushed. The trap is for *any* clone that edits an old blob and stages it.
- **Cron minute-0 pile-up 52.5 %** — unchanged, still the top behavioral finding.
- **`/audit` delta impact from my 12-file list = none.** The one real `/audit` deploy hazard (`deploy-competition-to-site.yml`, no concurrency group) **already has the fix landed** (`20f6e1cdad1`).
- **Sports "frozen-but-plausible"** and **`db_freshness.json` artifact-only seam** — unchanged.

## 3. Reproducible evidence (replaces `/tmp/qa3/*`)

```bash
cd /home/eaguiar2015/findtorontoevents_antigravity.ca
git fetch origin main
echo "origin/main=$(git rev-parse --short origin/main)"

# workflow count
git ls-tree -r --name-only origin/main -- .github/workflows | wc -l          # 375

# files in main not in this branch (should be the 3 below)
comm -13 <(git ls-tree -r --name-only HEAD -- .github/workflows | sort) \
         <(git ls-tree -r --name-only origin/main -- .github/workflows | sort)

# timeout must be 90 on main
git show origin/main:.github/workflows/dynamic-alpha-engine.yml | grep -n 'timeout-minutes'

# guardian commits? (expect upload-artifact, no git commit)
git show origin/main:.github/workflows/db-freshness-guardian.yml | grep -nE 'git |upload-artifact'

# db-freshness-check.yml gone?
git ls-tree -r --name-only origin/main -- .github/workflows | grep db-freshness
```

## 4. What is left (hand-off)

**Mine (v4), not yet done:**
- Apply E1–E10 edits into `03_DONE/GHACTIONS/` files (this doc records them; the source files still carry the old numbers).
- Replace `/tmp/qa3/*` references with §3 commands.
- Remove the 3 × `4645d08eee4` from `push_chain_impact.md` / `revert_runbook.md`.

**Blocked (needs human):**
- **B2** — which dashboard is authoritative (`audit_trail` live `/audit` vs `dashboard/` via `live_tracker.yml`). Gates the display-only AUDIT fixes (I6–I11).

**Deferred (decision-gated, not mine to start):**
- cron stagger (pilot `0 */2` tier only), concurrency backfill, `db_freshness.json` deletion, sports retire.

**Open COMS threads:**
- `ultra_free_together_bonsai` (Windows) — given the `listen`/`check` verb; awaiting its check-in.
- `opencode` (Windows) — no reply yet.
- Several Linux seats silent (only `deepseek-v4-flash` and Windows `deepseek-deepseek-flash` replied).