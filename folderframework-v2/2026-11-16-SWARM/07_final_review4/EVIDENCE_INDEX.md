# EVIDENCE_INDEX — folderframework-v2 audit deliverable

Every claim below links to a file path, line number, artifact, or command. Numbers that drift with
`origin/main` (≈ every 60 s) are marked **non-durable** and must be re-run before reuse.

---

## Source deliverables (this folder)
- `00_CHARTER.md` — scope + success criteria + roster.
- `03_DONE/AUDIT/audit_bugs_report.md` — Phase-1 bug list.
- `05_final_reviewv2/folderframework-v2_final_reviewv2.md` — peer reconciliation vs folderframework / v3 / v4.
- `07_final_review4/` — PLAN, IMPLEMENTATION_STEPS, TESTING_PLAN, FILES_TO_TOUCH, EVIDENCE_INDEX.

## Claim → evidence

| # | Claim | Evidence |
|---|---|---|
| RC1a | `checks.ghost_rows.ok=true` while `total_ghost_rows=22947` | `audit_dashboard/data/db_health.json` generated `2026-11-16T01:29:16.970480+00:00`; tier yellow |
| RC1b | `trading_picks.open_count=91705` vs `active_count=21` | same file; two different fields, not a contradiction |
| RC1c | `bt_backtest_trades.open_count=29247197` is a THIRD metric | same file; must not be mixed into the picks claim |
| RC2 | Break-even renders as loss | `dashboard/generate_dashboard.py:15` uses `> 0`; `live_picks.json` has 22/24 zeros |
| RC3 | Metric badges use `> 0` too | `dashboard/generate_dashboard.py:30-31` |
| RC4 | Side vocabulary mismatch | `dashboard/generate_dashboard.py:14` compares `== "LONG"`; observed sides `{BUY,LONG,SELL,SHORT}` in `live_picks.json` |
| RC5 | Win-rate counts break-even as loss | `audit_systems.py:35` `(p.get('pnl') or p.get('pnl_pct') or 0) > 0` |
| RC6 | None-unsafe aggregation | `enhanced_audit_dashboard.py:26` `p.get('pnl_pct', 0)` (default ignores explicit None) |
| RC7 | Contradictory Battleground WR | `audit_systems.py` → 5.3% from `ml_battleground/system_*`; `enhanced_audit_dashboard.py` → 56.9% from `battleground/data/closed_picks.json` |
| RC8 | Hub status stale | `hub/data/integrated_dashboard.json` `last_update=2026-03-02T19:37:56.256416`, `active_systems=0`, all `status="unknown"`, `registry_path="E:\\findtorontoevents_antigravity.ca\\..."` (Windows-only) |
| RC9 | Empty combos unexplained | `hub/data/winning_combos.json` `updated_at=2026-11-16T02:29:34Z`, `total_found=0` |

## Reproduce any numeric claim
```bash
cd /home/eaguiar2015/findtorontoevents_antigravity.ca/.kilo/worktrees/folderframework-v2
python3 audit_systems.py                # Battleground WR, hub status, combos count
python3 enhanced_audit_dashboard.py     # second WR source, scenario verdict
python3 dashboard/generate_dashboard.py # regenerate index.html from live_picks.json
```

## Retractions / corrections honored (do not re-raise)
1. "Money-Ready panel shows 'No data'" → **refined**: empty verdict array ≠ missing JSON; fix the empty-state label, not the data fetch.
2. "0 ghosts" claim → **retracted**: boolean gate passed, count did not.
3. "`db_freshness.json` has consumers" → **corrected** by v4: only Python reads it; display change is safe.

## Peer evidence used (AGENT_FOLDERFRAMEWORK main)
- `folderframework/2026-11-16-SWARM/04_final_review/...` and `06_final_review3/SYNTHESIS.md`
- `folderframework-v3/2026-11-16-SWARM/00_CHARTER.md` (canonical checklist)
- `folderframework-v4/07_final_review4/{PLAN,IMPLEMENTATION_STEPS,TESTING_PLAN,FILES_TO_TOUCH,EVIDENCE_INDEX}.md`

## Explicitly NOT verified
- Live HTTP body of `https://findtorontoevents.ca/audit/` (local JSON only).
- Which `_snapshot_prediction_market_entry` copy (`universal_pick_resolver.py:934` vs `dashboard_generator.py:5493`) the live page calls.
- Whether the prior 404-JS / Infinity emission on `audit-dashboard.yml` is still present on the current runner.