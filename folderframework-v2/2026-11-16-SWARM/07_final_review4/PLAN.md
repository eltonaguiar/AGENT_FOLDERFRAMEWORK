# PLAN — Audit Surface Truthfulness (folderframework-v2)

**Date:** 2026-11-16
**Domain:** AUDIT (audit dashboard claim correctness) for `eltonaguiar/findtorontoevents_antigravity.ca`
**Status:** Report + plan. No remediation applied. Human gate before merge.  
**Superseded as the single action plan by `../06_final_review3/FINAL_VERDICT.md`** (post-round-2 consolidation across all four peers). This file remains the AUDIT-domain detail package.

---

## 1. Problem statement

The audit dashboard and its generator scripts mislabel or mis-classify health. Boolean gates
(`checks.*.ok`, `banner_should_show`) report clean while underlying counts are non-zero
(`total_ghost_rows = 22947`, `trading_picks.open_count = 91705` vs `active_count = 21`).
The local dashboard generators have separate, smaller correctness bugs: break-even P/L is rendered
as a loss, a `BUY`/`SELL` side vocabulary is tested against `LONG`/`SHORT`, and win-rate math treats
zero-PnL trades as losses. None of this is a trading-strategy problem; it is a display/claim problem.

---

## 2. Root causes (with evidence)

| # | Root cause | Evidence (file:line / artifact) |
|---|---|---|
| RC1 | Boolean gate masks non-zero counts | `audit_dashboard/data/db_health.json` @ `db4cc06ed82`: `checks.ghost_rows.ok=true` but `data.total_ghost_rows=22947`; `trading_picks.open_count=91705`, `active_count=21` |
| RC2 | Break-even P/L renders as loss | `dashboard/generate_dashboard.py:15` `pnl_class = "positive" if pick["unrealized_pnl_pct"] > 0 else "negative"`; 22/24 live picks have `unrealized_pnl_pct == 0` (`dashboard/live_picks.json`) |
| RC3 | Metric badges mis-classify zero | `dashboard/generate_dashboard.py:30-31` `> 0` for `pnl_unreal_class` / `pnl_real_class` |
| RC4 | Side vocabulary mismatch | `dashboard/generate_dashboard.py:14` compares `pick["side"] == "LONG"`, but `live_picks.json` sides include `BUY`/`SELL` too (observed set `{BUY,LONG,SELL,SHORT}`) → all BUY/SELL render as the wrong badge |
| RC5 | Win-rate counts break-even as loss | `audit_systems.py:35` `(p.get('pnl') or p.get('pnl_pct') or 0) > 0` |
| RC6 | None-unsafe aggregation | `enhanced_audit_dashboard.py:26` `p.get('pnl_pct', 0)` does not guard explicit `None` (default only applies to missing key) |
| RC7 | Data-source drift between audit tools | `audit_systems.py` reads `ml_battleground/system_*/data/closed_picks.json` (WR 5.3%); `enhanced_audit_dashboard.py` reads `battleground/data/closed_picks.json` (WR 56.9%) — different files, contradictory headlines |
| RC8 | Stale hub status artifact | `hub/data/integrated_dashboard.json` `last_update=2026-03-02T19:37:56`, `active_systems=0`, all `status=unknown`, Windows `registry_path` |
| RC9 | Empty winning-combos not actionable | `hub/data/winning_combos.json` `total_found=0` (refreshed 2026-11-16 but empty) |

---

## 3. Proposed solution architecture

Three independent stages, ordered by risk. Each is revertible.

**A. Claim truth (docs/display, zero-risk).** Every health claim quotes `data.*` counts with `n`,
never `checks.*.ok`. Empty `money_ready` renders as "no classes ready (n=10 scanned)", not "No data".

**B. Generator correctness (code, low-risk).** Fix the five generator/audit bugs (RC2–RC6) with
break-even-aware classification and a single canonical side normalizer. Unify the audit data source
(RC7) so both tools quote the same WR.

**C. Plumbing refresh (behavioral, reversible).** Replace the stale `integrated_dashboard.json` with a
regenerated file (or mark it deprecated and have the dashboard read live source JSON directly). Populate
or explicitly mark `winning_combos.json` as "DNA run pending".

---

## 4. Phased rollout

### Phase A — Truth layer (now, zero-risk)
- Rewrite claim text on the audit surface to quote `total_ghost_rows` / `open_count` / `active_count`.
- Render empty `money_ready` explicitly with per-class `n`.

### Phase B — Generator fixes (separate PR, low-risk)
- Break-even → neutral class; `>= 0` semantics for positive/negative split.
- Single `normalize_side()` mapping `{BUY:LONG, SELL:SHORT, LONG:LONG, SHORT:SHORT}`.
- `None`-safe `sum()` with `if x is not None`.

### Phase C — Plumbing (decision-gated)
- Regenerate `integrated_dashboard.json` or deprecate it.
- Mark `winning_combos.json` status explicitly.

---

## 5. Risks and mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| "Fixing" display hides a real count | High | Never gate on `ok`; always print the count + tier |
| Side normalizer drops an unknown value | Med | Fall back to raw uppercase + neutral badge, log unknown sides |
| Unifying data source changes headline WR | Med | Document the chosen canonical file in the PLAN; keep both numbers annotated |
| Deleting ghost rows as part of a "display" fix | High | Deletion is out of scope; this plan is display-only |
| Regenerating hub JSON from a stale registry | Med | Prefer deprecation over regeneration until the registry path is portable (no Windows drive) |

---

## 6. Success metrics

- No audit-surface claim uses `checks.*.ok` as proof of zero.
- `grep -n '"negative"' dashboard/index.html` for a break-even pick → 0 (break-even never negative).
- `dashboard/live_picks.json` BUY/SELL picks render with correct long/short badges.
- `audit_systems.py` and `enhanced_audit_dashboard.py` quote the same Battleground WR.
- `integrated_dashboard.json` either has `active_systems > 0` or is explicitly deprecated in the UI.