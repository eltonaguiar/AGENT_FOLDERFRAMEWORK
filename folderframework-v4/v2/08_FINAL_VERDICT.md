# 08 — FINAL VERDICT (what to implement / pause / reject)

**Author:** `folderframework-v4` · **Date:** 2026-11-16 ~06:33Z · **Basis:** all four round-2 drops (`folderframework` e0143f1, `-v2` 69fca77, `-v3` a9deb2c, `-v4` mine) + external structure review.
**Rule applied:** implement = low-risk + reversible + ≥2 agents agree; pause = decision-gated or needs a measurement first; reject = charter/safety violation or disproven.

> This is my verdict. It does not merge anything; a human ratifies (Phase 0).

---

## 1. IMPLEMENT NOW  🟢

### A. Framework (all four agree; unblocks everything)
| # | Change | Owner | Risk |
|---|---|---|---|
| I1 | Ratify **v3 dated `YYYY-MM-DD-SWARM/`** as the only layout; v2-charter-folder + v4-flat are grandfathered, not retroactively moved | human | none |
| I2 | Adopt **v3 `swarm_librarian.py` v2.1** (`validate`, `--domains`, multi-src `collect`, `--auto-index`) as the single tool; retire the other two | human/v3 | none |
| I3 | Ship **`AGENT_PROMPT.md`** with every future task; add front-matter to new files | all | none |
| I4 | **Run `validate`** on all four folders; fix violations (v2 folder→file; v4 copy into dated root — copy, keep SHA) | v3, v2, v4 | low |
| I5 | **Errata pass on the v4 GHACTIONS drop** (recount at fresh SHA; purge `4645d08eee4`; fix `deploy-fte-index` verdict; guardian "never commits"; move `/tmp` evidence into `evidence/`; mark obsolete steps) | **v4 (me)** | none |

### B. Domain quick wins — display/correctness only (low risk, reversible)
*Gated on decision B2 below for *scope*, but each is safe regardless because it only changes presentation, never data or math.*

| # | Change | Owner | Evidence |
|---|---|---|---|
| I6 | **Neutral class for exact-zero PnL** — `dashboard/generate_dashboard.py:15,30` (display only; do NOT touch WR math) | v2 | 22/24 live picks have `unrealized_pnl_pct==0` |
| I7 | **`normalize_side()`** so `BUY`/`SELL` stop rendering short — `generate_dashboard.py:14` | v2 | sides `{BUY,SELL,LONG,SHORT}` |
| I8 | **Money-Ready empty state** renders "0 classes ready" + per-class verdict/wr/pf (never "No data") | v1 | `money_ready_verdict.json` `[]`, watch `[COMMODITY]` |
| I9 | **Label/remove hardcoded metrics** `sharpe` (0.3/1.35) & `win_rate: 55.0` — `enhanced_audit_dashboard.py:34,106-109` | v2 | hardcoded display lie |
| I10 | **Remove/annotate stale ghost note** `dashboard_enhancements.js:829-833` (prints "0" beside live 22,947) | v2 | v3 traced mechanism |
| I11 | **Claim language** = quote `data.total_ghost_rows`, `open_count`+`active_count`, never `ok`/`banner_should_show` | v1 | boolean gate masks counts |
| I12 | **GH push-safety guardrail**: never `git add .github/workflows/` wholesale; patch vs `origin/main`; never commit untracked `lint.yml` | **v4 (me)** | stale-fork trap 88367/15 |

---

## 2. PAUSE / DEFER  🟡  (needs a decision or a measurement first)

| # | Item | Why paused | Unblock |
|---|---|---|---|
| P1 | **db_freshness.json deletion** + doc sweep (old Step 7-B2) | guardian artifact-only; no consumer re-verified this round | re-run consumer grep, then P1 |
| P2 | **Cron stagger** | 192-file behavioral diff; main drift | pilot ONLY `0 */2` tier, recount at fresh SHA, measure 24 h |
| P3 | **Concurrency backfill** | large diff; self-deadlock risk on dual-mode | ~20-file batches, dual-mode first, `cancel-in-progress:false` |
| P4 | **Prediction snapshot dedup** | both copies are live (`resolver:1423` vs `dashboard_generator:1764`) — a real choice | contract-price unit test at both sites; markets stay shadow |
| P5 | **Sports retire banner + `.yml.disabled` rename** | needs GitHub-side `disabled_manually` confirmation + product call | one API pass; date-stamped banner |
| P6 | **Move v4 into dated root** | peer citations use current paths | copy (not move) after I5 errata; human OK |
| P7 | **v2 charter rescope** (battleground/incubator surfaces out of scope) | its S1/S2 chase metrics the charter never scoped | rescope to canonical `/audit` surfaces |

---

## 3. REJECT / DO NOT DO  🔴

| # | Item | Reason |
|---|---|---|
| R1 | Mass-delete 22,947 ghost rows or 91,705 open picks | hides duplicates; no tested rollback; label instead |
| R2 | Fabricate a winner / force `active_systems>0` or `total_found>0` | manufactures success; violates the sizing gate |
| R3 | Persist Kalshi/Polymarket emitter feeds | conflicts with shadow-only (PBO 0.603); never re-measured |
| R4 | Any real-money sizing | 6-gate (DSR>0.95, PBO<0.05, WFE>60%, live-Sharpe>0.5, n≥100) + human greenlight |
| R5 | Re-add `audit-dashboard.yml` `push:` trigger | 2026-05-19 cancel-cascade; hourly cron at :10 suffices |
| R6 | Bulk-delete 102 stale branches | sampling artifact (~1 h window); own dated swarm + human call |
| R7 | A third librarian / rewriting peers' folders | violates "single source of truth" + no-edit rule |
| R8 | Treat `ok`/`banner_should_show` as truth | boolean gate ≠ counts |
| R9 | Re-raise "4 whole-fleet push hazards" or "235 stale workflows" | both retracted/disproven |

---

## 4. OBSOLETE — already done, retire from the plan  ⚪

| # | Item | Status |
|---|---|---|
| O1 | Deploy-race concurrency on `deploy-competition-to-site.yml` (my Step 9) | **landed** on main as `20f6e1cdad1` → keep as regression watch only |
| O2 | Archive `db-freshness-check.yml` (my Step 7-A1) | **file no longer exists on main** → resolved externally |

---

## 5. Blocking decisions for the human (answer to start Phase 2)

| ID | Decision | My verdict |
|---|---|---|
| **B2** | Which dashboard is authoritative — live `/audit` (`audit_trail`) vs `dashboard/` (`live_tracker`) vs legacy? | **`audit_trail` for the public site.** `dashboard/` is secondary until proven served (`live_tracker.yml` may overwrite `index.html` from `alpha_engine/live_dashboard.html`). |
| B1 | Exact-zero PnL class | **neutral** (display), not a win; don't touch WR math in the same PR |
| B3 | Money-Ready "has data" | **render the empty verdict** (A); never require ≥1 ready |
| B4 | Move v4 into dated root | **copy, not move**, after I5; hold on your OK |
| B5 | Accept display-only scope for the domain quick wins | **yes** — low risk, reversible |

---

## 6. One-line verdict
**Implement the framework canon (I1–I5) and the display-only domain wins (I6–I12); pause anything that mutates data, rows, cron, or prediction feeds; reject anything that fabricates success or sizes real money; retire O1–O2.** Answer **B2** and the display wins can ship behind it.