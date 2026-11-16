# Final Review — folderframework

## What I agree with

- Isolation plus dated artifact folders is the right preservation model for this repo. Chat and shared checkouts lose work.
- The four domains in the charter (DB, GHACTIONS, AUDIT, PREDICTION) match the live failure modes.
- Final_review4 must stay a plan. Human gate before any merge.

## What I disagree with (and why, with evidence)

- Treating `checks.*.ok == true` as "problem gone" is wrong.
  - `audit_dashboard/data/db_health.json` generated_at `2026-11-16T01:29:16.970480+00:00` (worktree `folderframework` @ `db4cc06ed82`).
  - `checks.ghost_rows.ok` is true and `threshold_pass` is true, but `data.total_ghost_rows` is **22947** (tier yellow).
  - `checks.open_bloat.ok` is true, but `trading_picks.open_count` is **91705** and `active_count` is **21**.
  - `overall.any_red` is false and `banner_should_show` is false. A UI that reads those flags will report a clean bill while the counts are not zero.
- "Money-Ready has no data" is not the same statement as "money_ready is empty".
  - `audit_dashboard/data/money_ready_verdict.json` generated_at `2026-11-16T01:44:34.730014+00:00`.
  - `summary.money_ready` is `[]`. `summary.watch` is `["COMMODITY"]`. `n_classes` is 10.
  - `audit_dashboard/strategy_perf_by_class.html` already says `money_ready` is still empty.
  - `audit_dashboard/pick_funnel.html` points sizing at `money_ready_verdict.json` and states nothing is sized.
  - A "No data" tile (`audit_dashboard/cleanup_dashboard.py` emits `nc-nodata`) must not be used as a substitute for an empty verdict array.

## Missing evidence / open questions

- Live HTTP body of https://findtorontoevents.ca/audit/ was not re-fetched in this drop. Local JSON is the evidence.
- Whether `audit-dashboard.yml` still emits non-finite JSON on the current runner was not re-run. `alpha_engine/production_scanner.py` already has a NaN/Infinity sanitizer. Do not claim the 404-JS or Infinity bug is still open without a fresh Actions log.
- Two copies of `_snapshot_prediction_market_entry` exist (`audit_trail/universal_pick_resolver.py:934` and `audit_trail/dashboard_generator.py:5493`). Which one the live dashboard calls was not traced in this drop.

## Proposed changes to my own work after reading others

No peer reviews existed in `AGENT_FOLDERFRAMEWORK` at clone time (only `README.MD`, commit `05e6e8b`). This review stands alone until other worktree subfolders land.

## Risk rating

| Proposed fix | Risk |
|--------------|------|
| Display ghost and open counts from `data.*`, not `ok` | Low |
| Render empty `money_ready` as an explicit empty verdict with per-class n | Low |
| Deduplicate `_snapshot_prediction_market_entry` | Med — two call sites, easy to "fix" the unused one |
| Persist prediction-market emitter files | High — conflicts with shadow-only decision (PBO 0.603) |
| Any real-money sizing | High — blocked by charter |
