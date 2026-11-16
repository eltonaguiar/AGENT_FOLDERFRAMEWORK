# 00_CHARTER — Swarm 2026-11-16 (audit-system hygiene)

**Status:** template — fill roster + tick checklist before Phase 1 launches.
**Target codebase:** `eltonaguiar/findtorontoevents_antigravity.ca` (findtorontoevents.ca / tdotevent.ca / torontoevent.net).

## 1. Scope

Audit-system hygiene across four domains: **DB** (pick ledger integrity), **GHACTIONS** (workflow/deploy gaps), **AUDIT** (dashboard truthfulness), **PREDICTION** (prediction-market feeds), plus **CROSSCUTTING** for anything spanning domains.

## 2. Success criteria (verifiable, evidence-linked)

| # | Criterion | How verified |
|---|-----------|--------------|
| S1 | Ghost-row claim on the audit dashboard matches the live `db_health.json` figure (claimed: 22,947; dashboard reportedly shows "0") | curl `/audit/data/dashboard_data.json` + inspect `db_health.json` generator |
| S2 | Open-bloat figure reconciled: 91k "open" rows vs 21 actually-active picks | DB query result pasted in evidence |
| S3 | Money-Ready panel renders live data — no "No data" empty state on the live audit page | live URL check + screenshot |
| S4 | `dashboard_data.json` is strict JSON — no `Infinity`/`NaN` literals | parse with stdlib `json` |
| S5 | Prediction-market PnL uses contract prices (not spot), or the section is explicitly shadow-only | code pointer + sample calc |
| S6 | Every audit-page KPI tile is labeled with its sample size `n` | live URL check |

## 3. Non-goals (out of scope)

- No real-money sizing changes — `real_money.html` Lopez de Prado gates stay authoritative (DSR>0.95, PBO<0.05, WFE>60%, live-Sharpe>0.5, n≥100).
- No mass stale-workflow deletion ("235 stale workflows" was a sampling artifact; trigger-aware counts are ~20+12).
- No force-pushes, no history rewrites, no merging of `07_final_review4` output without human/merge-agent sign-off.
- No changes to production scan logic; findings only until Phase 5 plan is approved.

## 4. Known live URLs / key files

URLs:
- `https://findtorontoevents.ca/audit/` (mirrors: tdotevent.ca, torontoevent.net)
- `https://findtorontoevents.ca/audit/data/dashboard_data.json`
- `https://findtorontoevents.ca/audit/benchmark_proof.html`

Key files (repo-relative):
- `audit_trail/dashboard_generator.py`, `audit_trail/universal_pick_resolver.py`, `audit_trail/fetch_stock_prices.py`
- `audit_dashboard/template.html`, `audit_dashboard/dashboard_enhancements.js`, `audit_dashboard/data/`
- `alpha_engine/production_scanner.py`, `alpha_engine/config.py`
- `prediction_market_agents/orchestrator.py`, `alpha_engine/polymarket_signals.py`, `alpha_engine/kalshi_signals.py`
- `.github/workflows/audit-dashboard.yml`

## 5. Agent roster

| Agent | Worktree / branch | Role | Domain | Status |
|-------|-------------------|------|--------|--------|
| TBD   | `../wt-db-agent`  | Scout | DB | ☐ |
| TBD   | `../wt-gha-agent` | Scout | GHACTIONS | ☐ |
| TBD   | `../wt-audit-agent` | Scout | AUDIT | ☐ |
| TBD   | `../wt-pm-agent`  | Scout | PREDICTION | ☐ |
| TBD   | — | Evidence agent (short-lived) | all | ☐ |
| TBD   | — | Librarian | — | ☐ |
| TBD   | — | Synthesizer | final_review3/4 | ☐ |

## 6. Pre-final-review checklist (must be ticked before writing `04_final_review/`)

- [ ] Every claim in my deliverable has a path / SHA / URL / query result attached
- [ ] I reviewed at least two other agents' `03_DONE/` deliverables
- [ ] I checked the live site state today (not a cached copy)
- [ ] I checked recent GitHub Actions runs for my domain's workflows
- [ ] I inspected local uncommitted diffs / recent commits for relevant fixes already in flight
- [ ] No secrets, full dumps, or generated dashboards committed
