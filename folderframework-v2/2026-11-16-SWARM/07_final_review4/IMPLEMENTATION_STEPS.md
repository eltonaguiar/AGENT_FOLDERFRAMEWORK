# IMPLEMENTATION_STEPS — Audit surface truthfulness

Each step is independently revertible. Nothing here has been applied. Paths are relative to
`eltonaguiar/findtorontoevents_antigravity.ca`.

---

## Step 1 — Publish the audit record (this folder)
- **File(s):** `AGENT_FOLDERFRAMEWORK/folderframework-v2/**`
- **Change:** deposit charter, done report, v2 review, final_review4 package.
- **Risk:** none (separate repo).
- **Rollback:** `git revert <sha>` on `AGENT_FOLDERFRAMEWORK`.

## Step 2 — Claim truth: counts not booleans (display text)
- **File(s):** `audit_dashboard/template.html`, `audit_dashboard/dashboard_enhancements.js`
- **Change:** replace any "0 ghosts / clean" derivation from `checks.ghost_rows.ok` with
  `data.total_ghost_rows` and `data.tier`. Same for `open_bloat` → `trading_picks.open_count` +
  `active_count`.
- **Risk:** low (display only).
- **Rollback:** revert the hunk.

## Step 3 — Money-Ready empty-state labeling
- **File(s):** the money-ready panel source in `audit_dashboard/template.html` + `money_ready_verdict.json` consumer.
- **Change:** when `summary.money_ready == []`, render "No class money-ready (10 scanned)" with a
  per-class table using each class `n`, NOT the generic `nc-nodata` tile.
- **Risk:** low.
- **Rollback:** revert the hunk.

## Step 4 — Break-even P/L classification
- **File:** `dashboard/generate_dashboard.py:15,30,31`
- **Change:** `class = "positive" if x > 0 else ("negative" if x < 0 else "neutral")` and add a
  `.neutral` CSS class. Apply the identical rule to `pnl_unreal_class` and `pnl_real_class`.
- **Reason:** 22/24 live picks are break-even and currently render as red.
- **Risk:** low.
- **Rollback:** revert the hunk; remove `.neutral`.

## Step 5 — Canonical side normalizer
- **File:** `dashboard/generate_dashboard.py:14`
- **Change:** add `def normalize_side(s): return {"BUY":"LONG","SELL":"SHORT","LONG":"LONG","SHORT":"SHORT"}.get(str(s).upper(), "LONG")`
  and drive `side_class` from it. Unknown sides → neutral badge + `print` warning.
- **Reason:** `live_picks.json` mixes `BUY`/`SELL` with `LONG`/`SHORT`; BUY/SELL currently render as short.
- **Risk:** low.
- **Rollback:** revert the hunk.

## Step 6 — Win-rate None/zero safety
- **File:** `audit_systems.py:35`
- **Change:** `def _pnl(p): v = p.get('pnl'); return v if v is not None else p.get('pnl_pct')`
  then `wins = sum(1 for p in picks if (_pnl(p) or 0) > 0)` and count `== 0` as break-even (reported,
  not counted as loss). Document the win definition in a comment.
- **Risk:** low.
- **Rollback:** revert the hunk.

## Step 7 — None-safe aggregation
- **File:** `enhanced_audit_dashboard.py:26,103`
- **Change:** filter `isinstance(v,(int,float))` before summing; drop `p.get('pnl_pct', 0)` default and
  use explicit `if v is not None`.
- **Risk:** low.
- **Rollback:** revert the hunk.

## Step 8 — Unify audit data source (decision-gated)
- **File(s):** `audit_systems.py` (Battleground block), `enhanced_audit_dashboard.py` (Battleground block)
- **Change:** pick ONE canonical closed-picks path (recommend `battleground/data/closed_picks.json`
  because it is what the enhanced dashboard already reads and is non-empty) and have both tools read it,
  printing the source path next to the WR.
- **Risk:** med (headline number moves).
- **Rollback:** revert both hunks.

## Step 9 — Hub status: regenerate or deprecate
- **File:** `hub/data/integrated_dashboard.json`
- **Change:** either (a) regenerate with `active_systems > 0` from a portable registry, or (b) mark file
  deprecated and have the dashboard read live source JSON directly. Do not ship a Windows `registry_path`.
- **Risk:** med.
- **Rollback:** `git checkout <sha> -- hub/data/integrated_dashboard.json`.

## Step 10 — Winning combos status
- **File:** `hub/data/winning_combos.json`
- **Change:** add `"status": "dna_run_pending"` + `"note"` when `total_found == 0`, so the UI shows intent
  instead of an unexplained empty panel.
- **Risk:** low.
- **Rollback:** revert the hunk.

---

## Ordering rules
1. Steps 1–3 first (record + truth text).
2. Steps 4–7 next (generator correctness) — one PR.
3. Steps 8–10 are decision-gated; 8 must not ride with 9.
4. Never delete ghost/open rows as part of a display fix. Deletion is a separate, higher-risk job.