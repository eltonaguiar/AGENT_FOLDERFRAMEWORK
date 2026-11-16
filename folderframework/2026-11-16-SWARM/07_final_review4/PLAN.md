# PLAN — audit claim hygiene (pilot)

Status: plan only. Not a merge. Not money-ready.

## Problem statement

The audit surface can report a clean database and an empty Money-Ready panel while the underlying files contain large, specific counts. On 2026-11-16 the health file passed every boolean gate and still recorded 22947 ghost rows and 91705 open picks (21 active). The verdict file recorded zero money-ready classes. Those are different facts and must be shown as different facts.

## Root causes

- Boolean gates (`ok`, `threshold_pass`, `any_red`, `banner_should_show`) are not the counts. See `audit_dashboard/data/db_health.json` generated_at `2026-11-16T01:29:16.970480+00:00`.
- Open-bloat has three populations: `trading_picks.open_count` 91705, `trading_picks.active_count` 21, `bt_backtest_trades.open_count` 29247197. Mixing them produces the "91k vs 21" argument.
- Money-Ready is empty by verdict, not missing as a file. `summary.money_ready` is `[]` at `2026-11-16T01:44:34.730014+00:00`. A "No data" widget (`audit_dashboard/cleanup_dashboard.py`) is a different failure mode.
- Prediction-market entry snapshot exists in two modules. Promoting those feeds is out of scope while PBO stays 0.603 and the shadow decision holds.

## Proposed solution

Phase A — claims. Drive ghost, open, and active numbers from `checks.*.data`, and drive Money-Ready from `summary` plus per-class `verdict`, `wr`, `pf`. Label n on every tile.

Phase B — plumbing, only after a live fetch disagrees with the local JSON. Then inspect `audit-dashboard.yml` deploy output. Do not start here.

Phase C — prediction snapshot dedup, shadow-only. Pick the live call site, leave the other as a wrapper or delete it after a test proves which one runs. Do not persist new emitter files.

## Phased rollout

| Phase | Change | Gate to next |
|-------|--------|----------------|
| A | Display + docs only | Curl of live JSON matches the cited fields |
| B | Workflow/deploy only if Phase A live check fails | Actions run URL attached |
| C | Snapshot call-site dedup | Unit test shows contract price, not spot, and status remains shadow |

## Risks and mitigations

- Deleting rows to "make the number zero" hides duplicates instead of labeling them. Mitigation: no deletes in this plan.
- Fixing the unused snapshot copy. Mitigation: grep callers before editing.
- Another agent force-pushing this folder. Mitigation: write only under your worktree subfolder; cherry-pick, never force-push.

## Success metrics

- A quoted ghost claim equals `total_ghost_rows` (22947 on this snapshot, or the newer value if the file changed).
- A quoted open claim states both `open_count` and `active_count`.
- Money-Ready UI shows `money_ready: []` and does not imply a class is sized.
- No prediction-market pick is marked money-ready by this work.
