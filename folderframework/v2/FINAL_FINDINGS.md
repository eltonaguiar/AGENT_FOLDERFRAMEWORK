# Final findings — completed peers, v3 still open

Reviewed `eltonaguiar/AGENT_FOLDERFRAMEWORK` at `55f88cf` and the three finished worktrees. No source-repo code was changed. v3 recheck is at the bottom.

## What is done

| Agent | State | Keep |
|-------|--------|------|
| folderframework | Claim plan at `0969da9`, review overlay through `99117b6` | Quote `total_ghost_rows=22947`, `open_count=91705`, `active_count=21`. Empty `money_ready` is an empty verdict, not a missing file. |
| folderframework-v2 | Round 2 landed at `69fca77`. Dated SWARM, filled `07_final_review4`, charter file not folder. | Local generator bugs below. |
| folderframework-v4 | GHACTIONS plan plus `v2/05_FRAMEWORK_STRUCTURE_REVIEW.md` at `7b205ee` | Push-safety rule. Do not move their tree until a human asks. |
| folderframework-v3 | Still the `22a0d67` scaffold. Worktree clean. | Librarian is the tool to extend. Not a finished plan. |

## Verified from v2's round 2

- `dashboard/live_picks.json`: 24 active picks, 22 with `unrealized_pnl_pct == 0`. Sides are `BUY` 6, `SELL` 3, `LONG` 4, `SHORT` 11. `generate_dashboard.py:14` treats non-`LONG` as short, so BUY renders short.
- `enhanced_audit_dashboard.py:26` uses `p.get('pnl_pct', 0)`. An explicit `None` still crashes the sum. Line 103 is the older, already-coalesced site. Line 34 hardcodes `sharpe: 1.35` on the Battleground block; lines 107–109 still hardcode `55.0` / `0.3` for ML systems.
- `battleground/data/closed_picks.json`: n=123, WR 56.9%. `ml_battleground/system_a_filter` and `system_b_regime`: n=19, WR 5.3%. Those are different files. Unifying them would change the headline, not fix a display typo.
- `hub/data/integrated_dashboard.json`: `last_update=2026-03-02T19:37:56`, `active_systems=0`, registry path `E:\findtorontoevents_antigravity.ca\...`.
- `hub/data/winning_combos.json`: `total_found=0`, `updated_at=2026-11-16T02:29:34Z`. The file was touched and is still empty.

## Where I still disagree

- v2's plan says both "break-even → neutral" and "`>= 0` semantics". Those are different fixes. Neutral is the display fix. `>= 0` counts a scratch as a win. Do not ship both.
- Do not require `active_systems > 0` or `total_found > 0`. Deprecate the March hub file, or mark combos `dna_run_pending`. Do not generate a winner to clear the metric.
- Do not treat `dashboard/index.html` as https://findtorontoevents.ca/audit/. `live_tracker.yml:41-44` runs the generator and then may overwrite `dashboard/index.html` with `alpha_engine/live_dashboard.html`.
- Do not move v4's files in this round. v4 already asked to hold that on a human decision because other reviews cite the current paths.
- v3's Phase-5 templates are still blank. Endorsing v3 as the layout does not make its plan evidence.

## Final recommendations for now

1. Layout: v3 dated `YYYY-MM-DD-SWARM/` only. Add `--domains` and `validate` to v3's librarian when that agent finishes. No third script.
2. Next code, if a human accepts display-only: neutral class for exact zero in `generate_dashboard.py:15` and `:30`; `normalize_side()` for BUY/SELL; label the hardcoded Sharpe/WR. Leave WR math and row deletion alone.
3. Production audit claims stay on `db_health.json` and `money_ready_verdict.json`. Print counts, not `ok`.
4. GHACTIONS: no wholesale `git add .github/workflows/`. v4's cron stagger, sports rename, and `db_freshness.json` deletion stay unapproved.
5. Prediction markets stay shadow.

## Still blocked

- Live HTML of `/audit` was not fetched.
- Which `_snapshot_prediction_market_entry` the live page calls.
- Whether `alpha_engine/live_dashboard.html` exists on the runner that commits `dashboard/index.html`.
- v3 has not shipped `validate` or `--domains`.

## v3 recheck

Superseded. v3 landed `a9deb2c` after the interim note above. Librarian now has `validate` and `--domains`. Next steps are in `ACTION_PLAN.md`. The ghost-count lie they named is real at `audit_dashboard/dashboard_enhancements.js:829-831`, and it renders only when the tier-1 banner is red.
