# FILES_TO_TOUCH

Source repo: `eltonaguiar/findtorontoevents_antigravity.ca`  
Evidence SHA: `db4cc06ed82` on branch `folderframework`  
Nothing in that repo was modified by this drop. Paths below are the pilot touch list, not a diff.

| Path | Why | Risk |
|------|-----|------|
| `audit_dashboard/data/db_health.json` | Read-only evidence. Do not hand-edit. | Low if unread; High if overwritten |
| `audit_dashboard/data/money_ready_verdict.json` | Read-only evidence. Do not hand-edit. | High if a class is inserted |
| `audit_dashboard/pick_funnel.html` | Already documents the sizing lock. Update only the empty-state label if the live page says "No data". | Low |
| `audit_dashboard/strategy_perf_by_class.html` | Already states `money_ready` is empty. Keep that sentence accurate. | Low |
| `audit_dashboard/cleanup_dashboard.py` | Emits `No data`. Change only if that string is what the Money-Ready panel shows for an empty verdict. | Med |
| `audit_trail/dashboard_generator.py` | Candidate banner writer. Also defines `_snapshot_prediction_market_entry` at line 5493. | Med |
| `audit_trail/universal_pick_resolver.py` | Same function at line 934. Dedup only after caller trace. | Med |
| `.github/workflows/audit-dashboard.yml` | Touch only if live JSON is stale or 404. Push trigger was removed 2026-05-19; do not re-add it. | High |
| `.github/workflows/prediction-market-agents.yml` | Do not enable persistence in this pilot. | High |
| `.github/workflows/db-freshness-guardian.yml` | Reference only. | Low |

Framework repo (this drop, already written):

| Path | Why | Risk |
|------|-----|------|
| `folderframework/**` | Isolated end-state for this worktree | Low if other agents stay in their own subfolder |
