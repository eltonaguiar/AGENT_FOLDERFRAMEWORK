# EVIDENCE_INDEX

Captured 2026-11-16 from worktree `folderframework` at `db4cc06ed82`. Live HTTP was not fetched. Project decisions cited from saved project memory, not re-measured here.

| Claim | Evidence |
|-------|----------|
| Health file time | `audit_dashboard/data/db_health.json` `generated_at=2026-11-16T01:29:16.970480+00:00` |
| Host / DB | same file: `host=mysql.50webs.com`, `database=ejaguiar1_stocks`, `engine=MySQL 8.4.7` |
| Ghost rows are 22947 while the check passed | `checks.ghost_rows.ok=true`, `data.total_ghost_rows=22947`, `data.tier=yellow`, `data.threshold_pass=true` |
| Top ghost cohort | same file: MEMECOIN / meta_strategy / DOGEUSDT / LONG / pnl 1.3226 / n=3569 |
| Open vs active | `checks.open_bloat.data.trading_picks.open_count=91705`, `active_count=21`, `total_count=144407` |
| Backtest open count is a different population | `checks.open_bloat.data.bt_backtest_trades.open_count=29247197` |
| Boolean banner would stay hidden | `overall.any_red=false`, `overall.banner_should_show=false`, `checks_failed=0` |
| PnL integrity is not the ghost issue | `checks.pnl_integrity.data.sign_mismatch=130` of `sampled=24158` (0.54%), tier green |
| Money-ready list is empty | `audit_dashboard/data/money_ready_verdict.json` `generated_at=2026-11-16T01:44:34.730014+00:00`, `summary.money_ready=[]`, `summary.watch=["COMMODITY"]`, `summary.n_classes=10` |
| Class verdicts on that snapshot | FOREX NOT_READY wr 0.3219 pf 0.6596; CRYPTO NOT_READY wr 0.3576 pf 0.9163; EQUITY NOT_READY wr 0.592 pf 0.9392; COMMODITY WATCH wr 0.4017 pf 1.0256; BOND/ETF/CHEAP_STOCKS/FUTURES/MEME/PENNY_STOCK INSUFFICIENT_DATA |
| Page already says the list is empty | `audit_dashboard/strategy_perf_by_class.html` ("money_ready is still empty") |
| Sizing lock is documented | `audit_dashboard/pick_funnel.html` points at `/audit/data/money_ready_verdict.json` |
| "No data" string exists | `audit_dashboard/cleanup_dashboard.py` (`nc-nodata`) |
| Snapshot function is duplicated | `audit_trail/universal_pick_resolver.py:934`, `audit_trail/dashboard_generator.py:5493` |
| NaN sanitizer already exists in scanner | `alpha_engine/production_scanner.py` (recursive NaN/Infinity replacement). Not proof the live deploy is clean. |
| Workflows present | `.github/workflows/audit-dashboard.yml`, `prediction-market-agents.yml`, `db-freshness-guardian.yml` |
| Prediction markets stay shadow | project decision `prediction_markets_shadow_pbo`: PBO 0.603 |
| Copy trading rejected | project decision `prediction_market_copy_trading_rejected` |
| Real-money gate | project constraint `real_money_gating` |
| Framework repo baseline | `eltonaguiar/AGENT_FOLDERFRAMEWORK` commit `05e6e8b` contained only `README.MD` before this subfolder |
| Live URLs (not fetched) | https://findtorontoevents.ca/audit/ , https://findtorontoevents.ca/audit/pick_funnel.html , https://findtorontoevents.ca/audit/data/money_ready_verdict.json |

## Not verified

- Live HTML text.
- Latest GitHub Actions conclusion for `audit-dashboard.yml`.
- Which of the two snapshot functions the running dashboard calls.
