# Open questions

1. Does https://findtorontoevents.ca/audit/ currently print "0" ghosts or "No data" for Money-Ready? None of the four drops fetched the live HTML. Local JSON cannot answer the banner text.
2. Is `dashboard/index.html` deployed anywhere, or only generated locally? v2's success criterion 4 assumes it is the Money-Ready surface. I found no evidence that it is.
3. Who writes `hub/data/integrated_dashboard.json`? `active_systems=0` may be a stale file or a true count. The writer was not named.
4. Which `_snapshot_prediction_market_entry` runs in production? Both definitions exist. No caller trace in any drop.
5. Does v4's "88367 ahead / 15 behind" describe every worktree, or only the clone that wrote `revert_runbook.md`? Their evidence index says re-fetch before using the delta. This worktree was not measured here.
6. Is `dashboard_data.json` absent from this worktree because it is generated on the runner only? It is not at `audit_dashboard/data/dashboard_data.json` in `folderframework`. v3 S4 (no Infinity/NaN) is therefore unverified locally.
7. v3 S1 says the dashboard shows "0" ghosts. I showed the health file does not say 0. I did not show the page says 0. Those are different claims.
8. Should IC Analysis and per-tile `n` (v3 AUDIT todo) block the display fixes, or follow them? No agent produced evidence on either.
