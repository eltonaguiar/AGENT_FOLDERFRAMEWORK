# FILES_TO_TOUCH — every path, why, risk

Repo = `eltonaguiar/findtorontoevents_antigravity.ca` unless marked **AFF** (`eltonaguiar/AGENT_FOLDERFRAMEWORK`).

| Path | Action | Why | Risk |
|---|---|---|---|
| **AFF** `folderframework-v4/**` | add | Durable artifact deposit (this folder) | none |
| **AFF** `README.MD` (root) | leave | Framework spec; do not edit | none |
| `AGENTS.md` | edit (hunk) | Add push-safety rule + two-axis vocabulary | low |
| `.github/workflows/dynamic-alpha-engine.yml` | verify | Confirm `timeout-minutes: 90` @ line 115 | high if wrong |
| `.github/workflows/daily-price-refresh.yml.disabled` | leave | Dead 404 source; superseded by `daily-prices-yf-refresh.yml` | none |
| `.github/workflows/cross-db-consistency.yml` (deleted) | leave deleted | Dedup cleanup `c2393512637`; resurrecting = rollback of cleanup | med if resurrected |
| `.github/workflows/db-freshness-check.yml` | rename → `.disabled` (Step 7) | Manual-only committer; replace with guardian | low |
| `audit_dashboard/data/db_freshness.json` | delete from tree (Step 7) | Stale decoy; guardian artifact is source of truth | low (no consumer) |
| `.github/workflows/db-freshness-guardian.yml` | leave (source of truth) | Hourly runner; keep | none |
| `.github/workflows/{cron tiers}` (5 groups) | edit cron minute (Step 4) | De-congest minute-0 | med |
| `.github/workflows/{192 uncovered}` | add `concurrency:` (Step 5) | Prevent push-chain amplification | med |
| `.github/workflows/deploy-competition-to-site.yml` | add `concurrency:` (Step 9) | Only unguarded `/audit` push writer | med |
| `.github/workflows/deploy-fte-index.yml` | review (Step 9) | Writes `/audit/`; no concurrency group | med |
| `/live-monitor/sports-betting.html` | add banner (Step 8) | Frozen-but-plausible data is misleading | med |
| `.github/workflows/sports-*.yml` (5) | rename → `.yml.disabled` (Step 8) | Record disable intent in tree | med |
| `.github/workflows/lint.yml` (untracked) | **do not commit** | Push-no-filter + references untracked paths → guaranteed red | high |
| `AGENTS.md`, `HEARTBEAT.md`, `docs/MYSQL_ENV_SETUP.md` | edit refs (Step 7) | They point humans at the archived `db-freshness-check` | low |

## Never touch (stale-fork trap)
- Do **not** stage `.github/workflows/` wholesale from any local clone that is behind `origin/main`.
- Do **not** commit `.github/workflows/lint.yml` (untracked, never run, unbounded `push:`).
- Do **not** resurrect the 9 files deleted by `c2393512637` as part of any unrelated change.