# 01_TODO/GHACTIONS — workflow and deploy gaps

Phase-1 focus:

- `audit-dashboard.yml` health (hourly cron at :10; push trigger was removed 2026-05-19 — do not propose re-adding it without re-reading the removal rationale in AGENTS.md).
- Prediction-market signal workflows: are intended output files persisted or ephemeral?
- Deploy gaps: any 404'd JS chunks on live sites.
- Strict-JSON emission: find where `Infinity`/`NaN` could leak into `dashboard_data.json`.
- Triage per protocol: pull ~15–50 runs of history per workflow before classifying; a failed run with any subsequent run is considered fixed/intermittent.

Write findings here; promote to `03_DONE/GHACTIONS/` with run-URL evidence.
