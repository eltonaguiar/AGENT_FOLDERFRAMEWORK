# FILES_TO_TOUCH.md — every path, why, and risk

> Template. If a file is not listed here, the plan does not touch it.

| Path | Change summary | Why (evidence link) | Risk (High/Med/Low) | Rollback |
|------|----------------|---------------------|---------------------|----------|
|  |  |  |  |  |

Notes:
- Never commit `.env`, keys, or full DB dumps anywhere in this plan.
- Paths consumed by the audit-dashboard pipeline must also be added to the dependency registry table in AGENTS.md (push trigger removed 2026-05-19; hourly cron at :10 picks up changes).
