# Final verdict

All four agents are done. Base: `AGENT_FOLDERFRAMEWORK` `a9deb2c`. No source-repo code has been edited. This file is the implement-versus-pause call. `ACTION_PLAN.md` is the same list with file detail.

## Implement

One display-only PR. No deletes, no workflow edits, no WR-math change.

1. `audit_dashboard/dashboard_enhancements.js:829-831` — delete the frozen "0 ghost rows confirmed / all cleared as of 2026-05-31" sentence. Print `total_ghost_rows` only. The sentence is inside the red banner, so it is latent while `any_red` is false. It is still the wrong string.
2. Money-Ready copy — "0 classes ready" plus per-class verdict, wr, pf, and n. COMMODITY stays WATCH. Do not add a class to `summary.money_ready`.
3. `dashboard/generate_dashboard.py:15` and `:30` — exact zero is a neutral class, not red and not a win. 22 of 24 picks in `dashboard/live_picks.json` are zero.
4. Same file, line 14 — map BUY→long and SELL→short. Unknown sides stay visible. 9 of 24 picks are BUY or SELL and currently render short.
5. `enhanced_audit_dashboard.py:107-109` and `:34` — stop publishing hardcoded `win_rate: 55.0`, `sharpe: 0.3`, and Battleground `sharpe: 1.35`. Line 103 is already fixed. Line 26 must ignore explicit `None` so `sum` cannot throw.

Before 3 and 4, confirm `live_tracker.yml:43-44` is not overwriting `dashboard/index.html` with `alpha_engine/live_dashboard.html` on the runner. If it is, those two edits do not change the committed page. Ship 1, 2, and 5 anyway.

## Pause

| Item | Why |
|------|-----|
| Deleting 22947 ghost rows or 91705 open picks | Hides the count. No rollback tested. |
| Counting zero PnL as a win (`audit_systems.py:35` `>= 0`) | Changes WR. Neutral bucket only, and not in this PR. |
| Unifying Battleground 56.9% (n=123) with ml_battleground 5.3% (n=19) | Different files. Not a display typo. |
| Forcing `active_systems > 0` or `total_found > 0` | Hub file is stale (2026-03-02) and combos are honestly empty. Deprecate later. Do not generate a winner. |
| Cron stagger, 192-file concurrency backfill, sports rename, branch prune | v4 proposals. Re-pin at a fresh SHA first. Not this PR. |
| Deleting `db_freshness.json` | v3 says the legacy workflow is already gone. One consumer grep, then a separate PR. |
| Dedup of `_snapshot_prediction_market_entry` | v3 says both copies are called. Needs a contract-price test. Markets stay shadow. |
| Persisting Kalshi/Polymarket output | PBO 0.603. Copy trading stays rejected. |
| Moving v4 or v2 into a new dated root | Paths are already cited. Grandfather them. |
| Re-adding `audit-dashboard.yml` `push:` | Removed 2026-05-19 for cancel-cascade. Leave it off. |
| Another review round | Four agents converged. More prose will not change this list. |

## Already done — do not rebuild

- Canonical librarian is `folderframework-v3/tools/swarm/swarm_librarian.py` (`validate`, `--domains`).
- Next agent gets `folderframework-v3/AGENT_PROMPT.md`.
- GHACTIONS record is `folderframework-v4/`. Push-safety rule stands: fetch `origin/main` and do not stage `.github/workflows/` wholesale.
- Claim numbers stand: ghost rows 22947, open 91705, active 21, money-ready empty.

## Human still owns

Whether `dashboard/` is a public page (changes priority of items 3–4, not 1–2 or 5). Whether to delete `db_freshness.json` after the consumer check. Nothing else blocks the display PR.
