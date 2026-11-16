# 03 — Final recommendations (merged: v1–v4 content + framework canon + external review)

Priority: P0 = do now (hours), P1 = this week, P2 = scheduling decision. Each carries owner, effort, risk, evidence.

## A. Framework-consistency recommendations (this repo)

| # | Recommendation | Priority | Owner | Risk | Status |
|---|----------------|----------|-------|------|--------|
| R1 | Ratify canonical layout: dated `YYYY-MM-DD-SWARM/` root, fixed phase folders, `swarm_domains.txt`, run-stamped drops under `03_DONE/<DOMAIN>/`, evidence under `03_DONE/<DOMAIN>/evidence/` | P0 | human (D1) | none (forward-only) | canon written in `AGENT_PROMPT.md` |
| R2 | Single librarian: `folderframework-v3/tools/swarm/swarm_librarian.py` supersedes v1's subset variant | P0 | human (D1) | none | shipped + tested this drop |
| R3 | Every future agent receives `AGENT_PROMPT.md` verbatim in its task prompt | P0 | coordinator | none | file ready |
| R4 | Front-matter warn now, `--strict` in CI after one full swarm cycle | P1 | human (D7) | low | warn-level shipped |
| R5 | Grandfather peers' existing folders; no retroactive restructuring | P0 | all agents | none | stated in canon |

## B. Source-repo quick wins (display/correctness class — low risk, high trust yield)

| # | Recommendation | Priority | Effort | Risk | Evidence |
|---|----------------|----------|--------|------|----------|
| R6 | Ghost/open claims must quote `checks.ghost_rows.data.total_ghost_rows` and `trading_picks.open_count`+`active_count` — never the `ok` booleans (22,947 ghosts pass `ok` today) | P0 | small | low | v1 evidence chain, my byte-exact re-verify; live fetch 06:19Z |
| R7 | Money-Ready empty state renders "0 classes money-ready" + per-class verdict/wr/pf — the verdict file is live and `[]` is the truthful value; no "No data" conflation | P0 | small | low | v1; live `money_ready_verdict.json` 05:53Z still `[]`, watch `[COMMODITY]` |
| R8 | v2's bug 1+2: `> 0` → `>=` style break-even fixes in `dashboard/generate_dashboard.py:15,30` and `audit_systems.py:35` — but only after recording that these feed `live_tracker.yml`, not the canonical `/audit` pipeline | P1 | trivial | low | my line-level verification 06:12Z |
| R9 | Keep strict-JSON regression check in the loop: `dashboard_data.json` parses clean **today** (06:19Z) — the sanitizer is currently winning; add a CI parse gate so a regression fails loudly | P1 | small | low | my live fetch |

## C. Plumbing recommendations (medium risk)

| # | Recommendation | Priority | Effort | Risk | Evidence |
|---|----------------|----------|--------|------|----------|
| R10 | Retire v4 Step 9 (deploy-race concurrency) as **already landed** (`20f6e1cdad1`); convert to a regression watch in TESTING_PLAN | P0 | trivial | none | my live git check, 06:14Z |
| R11 | Retire v4 Step 7-A1 (`db-freshness-check.yml` is gone from main entirely) | P0 | trivial | none | `ls-tree` on `origin/main`, 06:14Z |
| R12 | Execute v4 Step 7-B2: delete committed `audit_dashboard/data/db_freshness.json` (stale-decoy RED since Oct) **with** doc-reference sweep (`AGENTS.md`, `HEARTBEAT.md`, `docs/MYSQL_ENV_SETUP.md`) in the same PR | P1 | small | low | v4 `orphan_items.md` Finding 1; my check: guardian artifact-only, JSON still in tree |
| R13 | Cron stagger: pilot ONLY the worst tier (`0 */2`, 15 files) using v4's deterministic `crc32%60` tables, recounted at a fresh SHA first; measure 24 h of run-start spread before touching other tiers | P1 | medium | medium | v4 `cron_stagger_plan.md`; count drift makes fresh recount mandatory |
| R14 | Concurrency backfill: dual-mode (schedule+push) files first, `cancel-in-progress: false` everywhere (never cancel FTP mid-upload); NOT a bulk 192-file PR — batches of ~20 with fresh SHAs | P2 | large | medium | v4 `push_chain_impact.md`; drift caveat |
| R15 | v4 errata pass before execution: reconcile the 16 internal inconsistencies (count bases, deploy-fte-index contradiction, incomplete SHA purge, TODOS self-contradictions) and commit the `/tmp`-referenced evidence or drop those claims | P0 | small | none | research summary in `01_PEER_CROSS_REVIEW.md` §v4 |

## D. Research/strategy recommendations (separate validation track)

| # | Recommendation | Priority | Risk |
|---|----------------|----------|------|
| R16 | Prediction-market snapshot dedup only after a unit test proves contract-price semantics at BOTH call sites (`universal_pick_resolver.py:934/1423`, `dashboard_generator.py:5493/1764`); markets stay shadow (PBO 0.603; copy-trading rejected) | P2 | medium |
| R17 | v2's research items (panic-sell logic review, strategy evaluation for winning history) — hold until its charter is rescoped to the canonical surfaces | P2 | low |

## Explicitly rejected / out of scope (with reason)

| Item | Reason |
|------|--------|
| Mass-deleting 22,947 ghost rows or 91,705 open picks to "make the number zero" | v1: hides duplicates instead of labeling them; no tested rollback |
| Persisting Kalshi/Polymarket emitter output | conflicts with shadow-only decision (PBO 0.603), never re-measured |
| Re-adding the `audit-dashboard.yml` push trigger | 2026-05-19 cancel-cascade incident; hourly cron at :10 is sufficient |
| Any real-money sizing | `real_money.html` Lopez de Prado gates (DSR>0.95, PBO<0.05, WFE>60%, live-Sharpe>0.5, n≥100) + human greenlight |
| Rewriting peers' folders in this repo to match canon | violates the framework's own no-edit rule |
| Bulk-deleting 102 stale branches (v4 Tier 1) | needs human call + its own dated swarm; cf. project correction about sampling-artifact-driven mass actions |
