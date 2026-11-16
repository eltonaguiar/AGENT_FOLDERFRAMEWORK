# FILES_TO_TOUCH — every path, why, risk

Repo = `eltonaguiar/findtorontoevents_antigravity.ca` unless marked **AFF** (`eltonaguiar/AGENT_FOLDERFRAMEWORK`).

| Path | Action | Why | Risk |
|---|---|---|---|
| **AFF** `folderframework-v2/**` | add | Durable artifact deposit (this folder) | none |
| **AFF** `README.MD` (root) | leave | Framework spec; do not edit | none |
| `audit_dashboard/template.html` | edit | Claim text → counts + `n`; empty money-ready state | low |
| `audit_dashboard/dashboard_enhancements.js` | edit | Same truth-layer change if it derives claims client-side | low |
| `dashboard/generate_dashboard.py` | edit (lines 14,15,30,31) | Break-even class + side normalizer | low |
| `dashboard/index.html` | regen via script | Re-render after generator fixes | low |
| `audit_systems.py` | edit (line 35) | Break-even-aware win-rate + comment | low |
| `enhanced_audit_dashboard.py` | edit (lines 26,103) | None-safe aggregation | low |
| `hub/data/integrated_dashboard.json` | regenerate OR deprecate | Stale 2026-03-02 file, `active_systems=0`, Windows path | med |
| `hub/data/winning_combos.json` | edit (add `status`/`note`) | Explain empty result as pending DNA run | low |
| `audit_dashboard/data/money_ready_verdict.json` | leave | Input data; consumers change, not this file | none |

## Never touch (out of scope)
- Do **not** delete ghost rows (`total_ghost_rows=22947`) or open picks (`open_count=91705`) as part of a display fix.
- Do **not** promote prediction markets out of shadow (PBO 0.603).
- Do **not** change any trading-strategy or real-money sizing gate.
- Do **not** delete `bt_backtest_trades.open_count=29247197` — it is a third metric that must stay distinct from `trading_picks.open_count`.