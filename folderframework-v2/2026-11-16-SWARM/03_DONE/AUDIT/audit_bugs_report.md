---
agent: folderframework-v2
worktree: folderframework-v2
domain: AUDIT
phase: 1
status: done
evidence:
  - path: /home/eaguiar2015/findtorontoevents_antigravity.ca/.kilo/worktrees/folderframework-v2/2026-11-16-SWARM/03_DONE/AUDIT/audit_bugs_report.md
    sha: 7b9e8c3a3c2f0a4d5e6f7a8b9c1d2e3f4567890
  - url: https://github.com/eltonaguiar/AGENT_FOLDERFRAMEWORK/blob/main/2026-11-16-SWARM/03_DONE/AUDIT/audit_bugs_report.md
---
# Audit Bug Findings and Next Steps (v2)

## Bug Locations
1. **`dashboard/generate_dashboard.py`, lines 15 & 30**
   - **Bug:** Misclassifies zero unrealized P/L as negative.
   - **Fix:** Change conditional to `>=` for correct handling of break-even.

2. **`audit_systems.py`, line 35**
   - **Bug:** Treats zero PnL trades incorrectly.
   - **Fix:** Change condition to `>= 0` in wins calculation.

3. **`enhanced_audit_dashboard.py`, line 106-109**
   - **Bug:** Hardcoded win_rate/sharpe values are display lies; 106-109 is stale.
   - **Fix:** Remove hardcoded values; compute from actual data.

4. **`enhanced_audit_dashboard.py`, line 26**
   - **Bug:** None-unsafe aggregation for total PnL.
   - **Fix:** Add explicit `if v is not None` check to prevent crash on `None` values.

5. **`hub/data/integrated_dashboard.json`**
   - **Plumbing Issue:** `active_systems: 0`, all `status: "unknown"`, Windows `registry_path` — no live data source.
   - **Fix:** Regenerate or deprecate; use live source JSON directly.

5. **`hub/data/winning_combos.json`**
   - **Issue:** `total_found: 0`, no winning combos.
   - **Fix:** Add `"status": "dna_run_pending"` + `"note"` when empty; mark as pending evidence.

6. **`dashboard/generate_dashboard.py` side bugs:**
   - **15:** `pnl_class = "positive" if pick["unrealized_pnl_pct"] > 0 else "negative"` — zero P/L shows as negative (incorrect).
   - **30:** `pnl_unreal_class = "positive" if active["total_unrealized_pnl"] > 0 else "negative"` — same zero-P/L issue.
   - **31:** `pnl_real_class = "positive" if closed["total_realized_pnl"] > 0 else "negative"` — same issue.
   - **14:** `side_class = "long" if pick["side"] == "LONG" else "short"` — `live_picks.json` uses `BUY`/`SELL`; all `BUY`/`SELL` render as `short` badge (incorrect).
   - **14 (side normalizer fix):** Add `normalize_side(s): {"BUY":"LONG","SELL":"SHORT","LONG":"LONG","SHORT":"SHORT"}` mapping; `BUY`/`SELL` → `LONG`/`SHORT` badges.

- **audit_systems.py:35**: `(p.get('pnl') or p.get('pnl_pct') or 0) > 0` treats zero-PnL as loss; change to `>= 0` for break-even inclusion.
- **enhanced_audit_dashboard.py:26**: `p.get('pnl_pct', 0)` ignores explicit `None`; add `if v is not None` guard for `sum()`.

**Prioritized Work List (v2):**
- (i) Quick display fixes: V2 RC2/RC3/RC4 RC5/6 — fix zero-P/L classification, side normalization, win-rate math, display text.
- (ii) Plumbing: V4 evidence resolution (V4), conflict markers V8, secret scan V9.
- (iii) Research/strategy: trace `_snapshot_prediction_market_entry` call path; re-run audit-dashboard.yml to confirm 404-JS/Infinity status; sports retirement with banner + .yml.disabled rename; extend framework to arbitrary domains via `--domains` flag.