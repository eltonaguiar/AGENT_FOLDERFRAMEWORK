# Action plan — next steps

Updated after `a9deb2c`. All four agents are done. The implement-versus-pause call is `FINAL_VERDICT.md`. This file is the step detail. No code in `findtorontoevents_antigravity.ca` has been changed.

## Now (no human decision)

1. Treat `folderframework-v3/tools/swarm/swarm_librarian.py` as the only librarian. Do not add another copy.
2. Hand `folderframework-v3/AGENT_PROMPT.md` to the next agent. New files use the front-matter in `LAYOUT_CONTRACT.md`.
3. Leave every published tree where it is. Do not move v4 into a dated SWARM unless a human asks for a librarian copy.
4. Do not delete ghost rows, fabricate `active_systems`, persist prediction-market feeds, re-add the `audit-dashboard.yml` push trigger, or `git add .github/workflows/` wholesale.

## Next code, if a human accepts a display-only PR

Order is blast radius, then certainty. Each step is its own commit so it can be reverted alone.

| Step | Change | Why | Gate |
|------|--------|-----|------|
| 1 | Replace the frozen sentence in `audit_dashboard/dashboard_enhancements.js:829-831` | It still says "2026-05-31: 0 ghost rows confirmed" and "all cleared". Verified in this worktree. It renders only inside the tier-1 red banner (`any_red` is false on the 01:29Z health file, so this is latent, not proof the live page shows 0 today). | Quote `total_ghost_rows`. Do not claim the count is zero. |
| 2 | Money-Ready empty state | Live claim from v3 (06:19Z): `money_ready=[]`, COMMODITY watch. I did not re-fetch. | Say "0 classes ready", with n. Do not insert a class. |
| 3 | `dashboard/generate_dashboard.py:15` and `:30` | 22 of 24 picks in `dashboard/live_picks.json` are exact zero and paint red. | Neutral class. Not `>= 0`. v3's R8 wording (`>=`) contradicts its own A1 ruling. Follow A1. |
| 4 | `normalize_side()` at `generate_dashboard.py:14` | Sides are BUY 6, SELL 3, LONG 4, SHORT 11. Non-LONG currently renders short. | Unknown sides stay raw. Do not drop them. |
| 5 | Label hardcoded metrics | `enhanced_audit_dashboard.py:107-109` is 55.0 / 0.3. Line 34 hardcodes Battleground Sharpe 1.35. Line 26 is None-unsafe. Line 103 is already coalesced. | Label or stop publishing the constants. Do not re-edit line 103. |

Before step 3, check whether `alpha_engine/live_dashboard.html` exists on the `live_tracker.yml` runner. Lines 43–44 copy it over `dashboard/index.html`. If that file is present, steps 3–4 do not change the committed page.

## Hold for a human

| ID | Question | Recommendation |
|----|----------|----------------|
| H1 | Ratify v3 layout and librarian forward-only? | Yes. Grandfather existing folders. |
| H2 | Is `dashboard/` a public page? | Blocks how hard to push steps 3–4. Public audit remains `audit_dashboard/` / `/audit`. |
| H3 | Delete committed `db_freshness.json`? | v3 says the legacy workflow is already gone and the file is a decoy. I did not re-grep consumers. One consumer check, then delete plus doc sweep, or leave it. |
| H4 | Cron stagger / concurrency backfill? | Not this PR. Pilot one tier later, after a fresh SHA. |
| H5 | Sports retire? | Not this PR. One GitHub API check of `disabled_manually` first. |
| H6 | Dedup `_snapshot_prediction_market_entry`? | v3 says both copies are called (`universal_pick_resolver.py:1423`, `dashboard_generator.py:1764`). I did not re-read those call sites. No dedup until a contract-price test exists. Markets stay shadow. |
| H7 | Move v4's folder? | No. Copy later if asked. |

## Do not do

- Count break-even as a win in `audit_systems.py:35` in the same change as the color fix. If touched, report break-even as its own bucket and leave WR math unchanged.
- Unify Battleground WR across `battleground/data/closed_picks.json` (n=123, WR 56.9%) and `ml_battleground/system_a_filter` (n=19, WR 5.3%). Different populations.
- Apply v4's 192-file concurrency sweep or resurrect deleted workflows.

## After v3 stops writing

v3's worktree was clean at this update, and `a9deb2c` is on main. If they push again, re-read only `folderframework-v3/v2/07_ROUND2_FINAL_FINDINGS.md` and `tools/swarm/swarm_librarian.py` before starting step 1. Do not restart the review.
