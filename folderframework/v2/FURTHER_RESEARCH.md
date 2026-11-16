# Further research

Not required to accept the display-only recommendations. Required before any delete, workflow edit, or strategy promotion.

1. **Live audit fetch.** `curl` https://findtorontoevents.ca/audit/ and https://findtorontoevents.ca/audit/data/money_ready_verdict.json. Compare `summary.money_ready` and `generated_at` to the local snapshot `2026-11-16T01:44:34Z`. Screenshot the ghost and Money-Ready strings.
2. **Strict JSON.** If `dashboard_data.json` exists only on the site, download it and parse with stdlib `json`. Local copy is missing in this worktree, so v3 S4 is open.
3. **Caller trace.** `rg` for `_snapshot_prediction_market_entry` callers. Do not edit either definition until one is shown unused.
4. **Hub writer.** Find the script that sets `active_systems` and `total_found`. Read it before calling 0 a failure.
5. **Hardcoded metrics.** Confirm `enhanced_audit_dashboard.py:107-109` is not overwritten by a later assignment. If it is the value that reaches HTML, that is the fix, not line 103.
6. **GHACTIONS re-pin.** Re-run v4's reproduce block against current `origin/main` before any workflow PR. Their pin `eb23252` and the 12-row delta are explicitly non-durable.
7. **Audit-dashboard runs.** v4 covered fleet push-safety, not whether the latest `audit-dashboard.yml` run deployed these JSON files. Pull ~15 runs before calling deploy broken. A failed run with a later success is skipped, per project constraint.
8. **IC Analysis and tile `n`.** Still unowned. Do not invent a pass.
9. **Prediction feeds.** Persistence decision stays closed: shadow, PBO 0.603, no copy trading. Research is limited to whether shown PnL uses contract price.
10. **Librarian patch, one place.** Add `--domains` and `validate` to `folderframework-v3/tools/swarm/swarm_librarian.py` only. Spec is in `LAYOUT_CONTRACT.md`. Do not implement a second copy here.
11. **Override path.** On a fresh checkout, check whether `alpha_engine/live_dashboard.html` exists before treating `generate_dashboard.py` as the writer `live_tracker.yml` commits.
