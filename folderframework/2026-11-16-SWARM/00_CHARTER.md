# 00_CHARTER — 2026-11-16 audit hygiene swarm

## Success criteria

1. Ghost-row claims on the audit surface match `audit_dashboard/data/db_health.json` (`checks.ghost_rows.data.total_ghost_rows`), not the boolean `ok` / `threshold_pass` flags.
2. Open-bloat claims distinguish `trading_picks.open_count` from `trading_picks.active_count`.
3. Money-Ready panel renders from `audit_dashboard/data/money_ready_verdict.json` and labels every tile with `n`. An empty `summary.money_ready` must display as empty, not as "No data" caused by invalid JSON.
4. Prediction-market PnL, if shown, uses contract prices via `_snapshot_prediction_market_entry`. Feeds stay shadow-only until a human greenlight. No real-money sizing.
5. A fresh agent can execute the plan from this folder plus the source repo, without chat history.

## Out of scope

- Real-money sizing. Gates remain: DSR>0.95, PBO<0.05, WFE>60%, live-Sharpe>0.5, n>=100, plus explicit human greenlight.
- Prediction-market copy trading (Kalshi/Polymarket). Rejected: zero-sum, adverse selection, fees, size mismatch.
- Promoting prediction markets out of shadow. Recorded PBO is 0.603.
- Force-push, shared working directories, or editing another agent's review file.
- Committing `.env`, keys, or database dumps.

## Known live surfaces

- https://findtorontoevents.ca/audit/
- https://findtorontoevents.ca/audit/pick_funnel.html
- https://findtorontoevents.ca/audit/data/money_ready_verdict.json
- https://github.com/eltonaguiar/findtorontoevents_antigravity.ca

## Key files (source repo)

- `audit_dashboard/data/db_health.json`
- `audit_dashboard/data/money_ready_verdict.json`
- `audit_dashboard/pick_funnel.html`
- `audit_dashboard/strategy_perf_by_class.html`
- `.github/workflows/audit-dashboard.yml`
- `.github/workflows/prediction-market-agents.yml`
- `.github/workflows/db-freshness-guardian.yml`
- `audit_trail/universal_pick_resolver.py` (`_snapshot_prediction_market_entry`)
- `audit_trail/dashboard_generator.py` (`_snapshot_prediction_market_entry`)

## Roster (this drop)

| Role | Agent | Isolation |
|------|-------|-----------|
| Librarian + synthesizer | folderframework | This subfolder only |
| Domain scouts | not assigned here | Own worktree subfolders |

## Rules

- Artifacts over chat. Commit markdown and small redacted JSON only.
- Evidence or the claim is invalid: file path, SHA, or live URL.
- Agents never edit each other's files.
- Disagreements in final_review3/4 resolve by evidence weight plus risk, not votes.
- Timeout: a worktree with no commits after 6 hours is archived by the librarian, not deleted.

## Checklist before writing a final_review

- [ ] Cited at least one path or URL per claim
- [ ] Did not edit another agent's file
- [ ] Marked risk High/Med/Low
- [ ] Stated what was not verified
