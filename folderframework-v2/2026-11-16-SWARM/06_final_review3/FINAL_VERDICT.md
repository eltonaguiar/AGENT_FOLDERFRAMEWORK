# FINAL VERDICT — folderframework-v2

**Date:** 2026-11-16  
**Scope:** all four round-2 drops (`folderframework`, `folderframework-v2`, `folderframework-v3`, `folderframework-v4`) plus the external framework review.  
**Position:** synthesizer verdict, not a vote. Every item is ranked by **evidence weight + reversibility**. Nothing below has been applied to the source repo.

---

## 1. All peers are complete

| Agent | State | Keeps |
|---|---|---|
| `folderframework` (v1) | Complete | D1–D14 decision register; `PEER_REVIEW`, `LAYOUT_CONTRACT`, `AGENT_PROMPT`, `PHASE_GATES`; production audit claim-hygiene findings |
| `folderframework-v2` | Complete | Canonicalized dated SWARM; AUDIT plan with 9 root causes; framework templates; local dashboard bug list |
| `folderframework-v3` | Complete | Librarian v2.1 (`scaffold --domains`, `validate`, multi-source `collect`, evidence dirs); canon/alignment pass; round-2 final findings |
| `folderframework-v4` | Complete | GHACTIONS audit + revert runbook; retraction of false P1 push-hazard; two-dashboard split |

Convergence is now strong: all four plus the external reviewer agree on the canonical layout, the librarian as the single tool, mandatory prompt/front-matter, non-destructive display work, shadow-only prediction markets, and a human gate before any workflow or strategy change.

---

## 2. Implement now (P0 / P1 — low risk, reversible)

### A. Framework consistency (highest leverage, zero production risk)
1. **Ratify the dated `YYYY-MM-DD-SWARM/` root as the only forward layout.** Grandfather existing folders; do not rewrite peer trees. Evidence: v1 `D10/D11`, v3 canon, external review gap #1.
2. **Make `folderframework-v3/tools/swarm/swarm_librarian.py` the single librarian.** It already ships `--domains`, `validate`, multi-source `collect`, and `evidence/<DOMAIN>/`. Do not fork a third copy. Evidence: v3 round-2; external review gap #2/#3.
3. **Ship `AGENT_PROMPT.md` verbatim to every future agent.** Placement, filename pattern, front-matter, phase gates, no-edit rule. Evidence: v1 `AGENT_PROMPT.md`; v3 adoption.
4. **Add the missing validator checks from v2 `templates/VALIDATE_SPEC.md`** to the canonical librarian next pass: V4 evidence-resolution, V8 conflict-marker scan, V9 secret patterns. Evidence: v3 §C-8.
5. **Warn-level front-matter now; `--strict` CI after one full cycle.** Do not hard-fail before calibrating on real violations. Evidence: v1 `D7`.

### B. Production audit claim hygiene (display-only, verified live)
6. **Every ghost/open/active claim must quote `db_health.json` `data.*` counts, never `checks.*.ok` or `banner_should_show`.** Current truth: `total_ghost_rows=22947`; `trading_picks.open_count=91705` vs `active_count=21`; `bt_backtest_trades.open_count=29247197` is a third metric. Evidence: v1/v2/v4; live fetch 2026-11-16T06:19Z.
7. **Money-Ready empty state renders explicitly:** “0 classes money-ready (n=10 scanned)” + per-class `n`/wr/pf. COMMODITY stays WATCH. Never a fabricated ready class. Evidence: `money_ready_verdict.json` @ 2026-11-16T01:44:34Z / live 05:53Z.
8. **Fix the frozen “0 ghosts” remediation string at `audit_dashboard/dashboard_enhancements.js:829-833`.** The live count is rendered correctly elsewhere in the same banner; this hardcoded sentence is the lie. Evidence: v3 §3 fact #1.
9. **Keep a strict-JSON regression gate for `dashboard_data.json`** — it parses clean today; add a parse check so Infinity/NaN regressions fail loudly. Evidence: v3 R9.

### C. Local secondary dashboard bugs (only after D-blocker is answered)
10. **Break-even P/L → neutral class** in `dashboard/generate_dashboard.py:15,30`; add `.neutral`. Evidence: 22/24 live picks have `unrealized_pnl_pct == 0`; v3 verification.
11. **`normalize_side()` for `BUY`/`SELL`** in `generate_dashboard.py:14`; currently BUY renders as short. Evidence: sides `{BUY:6,LONG:4,SHORT:11,SELL:3}` → 9/24 mis-badged.
12. **Label or remove hardcoded `win_rate: 55.0` / `sharpe: 0.3`** at `enhanced_audit_dashboard.py:106-109`. Do **not** re-fix the already-coalesced None site at line 103. Evidence: v1 finding; v4 confirmation.
13. **Neutral-bucket design for `audit_systems.py:35`**: report break-even separately; do not silently count it as a win or a loss. Evidence: v3 adjudication A1.

---

## 3. Pause (decision-gated — do not execute without an explicit human answer)

| Item | Why paused | Gate |
|---|---|---|
| Delete ghost rows (22,947) / open picks (91,705) | Display fix only; deletion has no tested rollback and hides duplicate lineage | Human decision D-row-delete (never approved) |
| Generate winning combos to satisfy `total_found > 0` | Manufactures a success metric; `total_found=0` may be the truth | Human decision D5; otherwise mark `dna_run_pending` |
| Force `active_systems > 0` in hub JSON | `active_systems=0` may be truth; faking a row is worse than deprecation | Human decision D4 |
| Bulk cron stagger across 192 files | Behavioral change; counts drifted between v4 snapshots (356/358/373) | Pilot the worst tier `0 */2` (15 files) after fresh-SHA recount; 24 h observation first |
| Bulk concurrency backfill | Same drift + dual-mode feedback risk | Batches of ~20, dual-mode first, `cancel-in-progress: false` on FTP |
| `db_freshness.json` deletion + archive legacy | v4 Step 7-A1 is **already moot** (`db-freshness-check.yml` gone on main); 7-B2 still needs doc sweep | Delete file + sweep `AGENTS.md`, `HEARTBEAT.md`, `docs/MYSQL_ENV_SETUP.md` in one PR |
| Sports retire/banner/rename | `disabled_manually` flags are GitHub-side, UNVERIFIED in git | One `gh api` pass on last-run dates + flags; then dated banner + `.yml.disabled` rename |
| Dedup `_snapshot_prediction_market_entry` | Both copies are live in different modules; wrong-direction dedup changes PM PnL | Caller trace + contract-price unit test first |
| Any real-money sizing | Gates: DSR>0.95, PBO<0.05, WFE>60%, live-Sharpe>0.5, n≥100 + human greenlight | Blocked by charter / memory constraint |
| Persist Kalshi/Polymarket feeds / promote out of shadow | Shadow-only decision stands (PBO 0.603) | Never in this swarm |
| Re-add `audit-dashboard.yml` push trigger | 2026-05-19 cancel-cascade incident | Never |

---

## 4. Decisions required from the human (blocking order)

1. **B2 / D14 — Which dashboard is authoritative?** Is committed `dashboard/index.html` served anywhere, or does `live_tracker.yml:43-44` overwrite it from `alpha_engine/live_dashboard.html`? This gates whether the entire local-dashboard fix list (items 10–13) matters to the public site.
2. **D1 — Ratify canonical layout + librarian forward-only.** Grandfather existing folders.
3. **D3 — Approve deleting stale `audit_dashboard/data/db_freshness.json`** + doc sweep.
4. **D4 — Sports: retire-with-banner vs leave frozen** after the API pass.
5. **D6 — Cron stagger scope: pilot-only vs full.**
6. **Q2 — Is `hub/data/*` a live surface?** If dead, retire rather than repair.
7. **Q7 — Sole owner per domain per swarm** (GHACTIONS is currently claimed by both `folderframework-v4` and an outside `ghactions-*` fleet).

---

## 5. What can be stopped entirely

- **No further scaffold duplication.** Four folders already exist; the librarian is chosen. Stop creating new folder shapes.
- **No mass stale-workflow deletion.** The “235 stale” number was a sampling artifact; real stale/never-run is ~20 + 12. Do not drive mass action off that metric.
- **No branch-pruning bulk pass.** Tier 0 (7 merged branches) is safe; the remaining ~102 idle branches need their own dated swarm with API-verified inactivity.
- **No prediction-market persistence or copy-trading work.** Structurally rejected (zero-sum, adverse selection, fees, size mismatch).
- **No strategy promotion from the empty `money_ready_verdict.json`.**

---

## 6. Final one-line recommendation

**Implement the converged structural track (canon + librarian + prompt + validate) immediately; implement the production audit claim-hygiene display fixes (counts-not-booleans + empty Money-Ready + frozen ghost note) as the next low-risk PR; pause every row deletion, combo fabrication, cron sweep, sports rename, and prediction-feed change until its named decision is explicitly answered by a human.**

This is the highest-trust, lowest-risk path and matches the convergent position of all four agents plus the external review.