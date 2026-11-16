# TESTING_PLAN — Audit surface truthfulness

Every step in `IMPLEMENTATION_STEPS.md` maps to at least one check here.

---

## 1. Static verification (stdlib JSON + grep)

```bash
# T1 — strict JSON parse of all audit data files
python3 - <<'PY'
import json
for f in ["audit_dashboard/data/db_health.json",
          "audit_dashboard/data/money_ready_verdict.json",
          "audit_dashboard/data/dashboard_data.json",
          "hub/data/integrated_dashboard.json",
          "hub/data/winning_combos.json"]:
    try:
        json.load(open(f)); print("PASS", f)
    except Exception as e:
        print("FAIL", f, e)
PY

# T2 — no Infinity/NaN literals in dashboard_data.json (known prior bug class)
grep -nE 'Infinity|NaN' audit_dashboard/data/dashboard_data.json || echo "PASS: no non-finite literals"

# T3 — claim text must not use boolean gates as proof
grep -n 'checks.*\.ok\|banner_should_show' audit_dashboard/template.html || echo "PASS: no boolean-gate claims"

# T4 — break-even never classified negative
grep -n 'pnl_class\|pnl_unreal_class\|pnl_real_class' dashboard/generate_dashboard.py

# T5 — side vocabulary unified
grep -n 'LONG\|BUY\|normalize_side' dashboard/generate_dashboard.py
```

## 2. Per-step acceptance tests

| Step | Test | Expected |
|---|---|---|
| 1 Publish | `find AGENT_FOLDERFRAMEWORK/folderframework-v2 -type f \| wc -l` | ≥ 8 files |
| 2 Truth text | grep claims for `total_ghost_rows` / `open_count` | each count present with `n` |
| 3 Money-Ready | load page with empty verdict | "No class money-ready (10 scanned)" + per-class `n`; no generic `nc-nodata` |
| 4 Break-even | run `dashboard/generate_dashboard.py` on `live_picks.json` (22 zeros) | 0 picks classed `negative` for P/L; neutral used |
| 5 Side badges | inspect rendered rows for BUY/SELL | long badge for BUY/LONG, short for SELL/SHORT |
| 6 Win-rate | `python3 audit_systems.py` | break-even reported separately, not silently counted as loss |
| 7 Aggregation | `python3 enhanced_audit_dashboard.py` | no TypeError on `None` pnl_pct |
| 8 Data source | both tools' Battleground WR | identical number + same source path printed |
| 9 Hub status | read `integrated_dashboard.json` | `active_systems > 0` or explicit `deprecated` flag + live read |
| 10 Combos | read `winning_combos.json` | explicit `dna_run_pending` when `total_found == 0` |

## 3. Live verification (needs network)

```bash
curl -fsS -o /dev/null -w "%{http_code}\n" https://findtorontoevents.ca/audit/
curl -fsS https://findtorontoevents.ca/audit/data/dashboard_data.json -o /tmp/dd.json
python3 -c "import json;d=json.load(open('/tmp/dd.json'));print('parsed OK', len(json.dumps(d)))"
```

## 4. Regression checklist (human)

- [ ] No "0 ghosts" claim anywhere while `total_ghost_rows > 0`.
- [ ] Break-even picks show neutral color, not red.
- [ ] BUY picks no longer render as short badges.
- [ ] `audit_systems.py` and `enhanced_audit_dashboard.py` agree on Battleground WR.
- [ ] Ghost/open rows still exist (no accidental deletion).
- [ ] Empty `money_ready` shows intent + `n`, not "No data".
- [ ] Prediction-market section remains shadow-only (PBO 0.603 unchanged).

## 5. Negative tests (must NOT regress)

- `grep -c total_ghost_rows` on the audit template → ≥ 1.
- `git grep -n "banner_should_show" -- '*.html' '*.js'` → only as data, never as the sole proof.
- `git grep -ni "real.money" -- prediction_market_agents alpha_engine/polymarket_signals.py alpha_engine/kalshi_signals.py` → no new real-money sizing paths.