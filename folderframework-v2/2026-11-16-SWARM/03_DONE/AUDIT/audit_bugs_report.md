# Audit Bug Findings and Next Steps (v2)

> **Errata (2026-11-16):** item 3 below cites `enhanced_audit_dashboard.py:103` as the None-unsafe site.
> That line already coalesces explicit `None` (2026-06-04 comment). The current None-unsafe site is
> **`enhanced_audit_dashboard.py:26`** (`p.get('pnl_pct', 0)`); the worse adjacent display lie is the
> hardcoded `win_rate: 55.0` / `sharpe: 0.3` at **lines 106–109**. See `06_final_review3/FINAL_VERDICT.md`.

## Bug Locations
1. **`dashboard/generate_dashboard.py`, lines 15 & 30**
   - **Bug:** Misclassifies zero unrealized P/L as negative.
   - **Fix:** Change conditional to `>=` for correct handling of break-even.

2. **`audit_systems.py`, line 35**
   - **Bug:** Treats zero PnL trades incorrectly.
   - **Fix:** Change condition to `>= 0` in wins calculation.

3. **`enhanced_audit_dashboard.py`, line 103**
   - **Bug:** Total PnL calculation aggregates incorrectly for missing fields.
   - **Fix:** Confirm all picks have correct fields before summation.

4. **`hub/data/integrated_dashboard.json`**
   - **Plumbing Issue:** `active_systems: 0`, all `status: "unknown"`, Windows `registry_path`.
   - **Fix:** Regenerate or deprecate; use live source JSON directly.

5. **`hub/data/winning_combos.json`**
   - **Issue:** `total_found: 0`, no winning combos.
   - **Fix:** Run algorithmic strategies or mark as "dna_run_pending".

6. **`dashboard/index.html` side badges**
   - **Bug:** `BUY`/`SELL` renders as `short`/`short` (wrong class).
   - **Fix:** Normalize `side` to `LONG`/`SHORT` via `normalize_side()`.

7. **`audit_systems.py` data source**
   - **Issue:** Uses `ml_battleground` for Battleground WR (5.3%) but `battleground/data/closed_picks.json` for enhanced dashboard (56.9%).
   - **Fix:** Unify to canonical `battleground/data/closed_picks.json` for both.

## Prioritized Work List (v2)

### (i) Quick display / correctness fixes (≤1 PR)
- Fix `pnl_class`, `pnl_unreal_class`, `pnl_real_class` to handle zero P/L as neutral.
- Ensure `dashboard/index.html` does not show generic "No data" when verdict is empty.
- Add 6-item pre-final-review checklist to every agent prompt (see v2 charter).

### (ii) Plumbing fixes (medium effort)
- Promote v3 `swarm_librarian.py` + scaffold as canonical; add `--domains` and `validate` subcommands.
- Move v4 GHACTIONS content into proper dated `2026-11-16-SWARM/` structure.
- Add front-matter validation to the librarian (fail on missing `agent`, `domain`, `evidence`).
- Enforce worktree naming `wt-<domain>-<short-id>` via prompt contract.

### (iii) Research / strategy work (decision-gated)
- Trace exact `_snapshot_prediction_market_entry` call path on live site.
- Re-run `audit-dashboard.yml` with fresh Actions log to verify 404-JS / Infinity fix.
- Decide sports retirement banner (cosmetic vs. explicit intent) and rename 5 `sports-*.yml` → `.yml.disabled`.
- Extend framework to support arbitrary new domains via `--domains` flag or config file.
- Extend evidence attachment to `evidence/` subfolder (raw JSON/snippets, not inline).