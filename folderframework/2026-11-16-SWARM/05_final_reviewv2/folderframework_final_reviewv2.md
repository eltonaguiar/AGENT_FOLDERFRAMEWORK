# Final Review v2 — folderframework

No Phase-2 peer files existed to reconcile. Recommendations below are the revised set after re-reading the local evidence, not after a vote.

## Revised recommendations

1. Truth layer for DB hygiene is a display and claim fix first. Do not delete 22947 ghost rows or 91705 open rows in the pilot.
2. Money-Ready work is labeling, not promotion. `summary.money_ready == []` as of `2026-11-16T01:44:34Z`. COMMODITY is WATCH (wr 0.4017, pf 1.0256), not ready.
3. Prediction-market work stops at "shadow, contract-price snapshot, no copy trading". Do not persist new emitter feeds in this plan.
4. GHACTIONS items stay investigative until a run log is attached. Do not treat historical 404/Infinity notes as current without a run URL.

## Resolved disagreements

- "0 ghosts" vs 22947: resolved. The boolean gate passed; the count did not. Claims must quote `total_ghost_rows`.
- "91k open vs 21 active": resolved as two different fields. `open_count=91705`, `active_count=21` on `trading_picks` in the same file. `bt_backtest_trades.open_count=29247197` is a third number and must not be mixed into the picks claim.

## Remaining blockers

- No second agent has reviewed this folder yet.
- Live site HTML was not fetched.
- Call-path for `_snapshot_prediction_market_entry` is unverified.
