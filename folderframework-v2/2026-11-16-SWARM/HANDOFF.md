# HANDOFF — folderframework-v2 swarm

**Repo:** `eltonaguiar/AGENT_FOLDERFRAMEWORK`  
**Local worktree:** `findtorontoevents_antigravity.ca/.kilo/worktrees/folderframework-v2`  
**Artifact root:** `folderframework-v2/2026-11-16-SWARM/`  
**Date:** 2026-11-16  
**Status:** research, framework scaffolding, peer synthesis, and final verdict complete. No source-repo code changes applied.

---

## 1. What I did

- Ran the audit tooling (`audit_systems.py`, `enhanced_audit_dashboard.py`, dashboard generator) and located concrete bugs with evidence.
- Normalized this folder into the canonical dated SWARM layout (charter file, phase folders, evidence dirs, templates).
- Reviewed all peers: `folderframework` (v1), `folderframework-v3` (canon/librarian), `folderframework-v4` (GHACTIONS), plus the external structure review.
- Produced a consolidated final verdict and a paused/decision-gated implementation order.

## 2. Files delivered

```
folderframework-v2/2026-11-16-SWARM/
├── 00_CHARTER.md
├── 01_TODO/{AUDIT,CROSSCUTTING,DB,GHACTIONS,PREDICTION}
├── 02_IN_PROGRESS
├── 03_DONE/AUDIT/audit_bugs_report.md
├── 04_final_review
├── 05_final_reviewv2/folderframework-v2_final_reviewv2.md
├── 06_final_review3/FINAL_VERDICT.md
├── 07_final_review4/
│   ├── PLAN.md
│   ├── IMPLEMENTATION_STEPS.md
│   ├── TESTING_PLAN.md
│   ├── FILES_TO_TOUCH.md
│   ├── EVIDENCE_INDEX.md
│   └── NEXT_STEPS_ACTION_PLAN.md   (superseded pointer)
├── 99_archive
└── templates/{AGENT_PROMPT.md,swarm_config.example.yaml,VALIDATE_SPEC.md}
```

## 3. Key findings (evidence)

- `audit_dashboard/data/db_health.json`: `checks.ghost_rows.ok=true` while `data.total_ghost_rows=22947`; `trading_picks.open_count=91705` vs `active_count=21`; `bt_backtest_trades.open_count=29247197` is a separate metric. Claims must quote `data.*`.
- `dashboard/generate_dashboard.py:14,15,30,31`: break-even renders as loss; `BUY`/`SELL` mis-badged because code tests only `== "LONG"`.
- `audit_systems.py:35`: zero-PnL trades counted as losses.
- `enhanced_audit_dashboard.py:26` None-unsafe aggregation; lines 106–109 hardcode `win_rate: 55.0` / `sharpe: 0.3`.
- Data-source drift: `audit_systems.py` (5.3% WR) vs `enhanced_audit_dashboard.py` (56.9% WR) read different Battleground files.
- `hub/data/integrated_dashboard.json` stale (2026-03-02, `active_systems=0`, Windows registry path); `hub/data/winning_combos.json` `total_found=0`.
- v3 located the live “0 ghosts” lie: `audit_dashboard/dashboard_enhancements.js:829-833` hardcoded remediation string.
- v4: no whole-fleet push hazard on main; stale-fork trap; minute-0 cron pile-up; `/audit` deploy concurrency already landed outside the swarm (`20f6e1cdad1`).

## 4. Final recommendation

**Implement now (low risk):**
1. Ratify the dated `YYYY-MM-DD-SWARM/` layout + v3 librarian as canonical; ship `AGENT_PROMPT.md` + front-matter.
2. Add v2 validator extras V4/V8/V9 to the canonical librarian.
3. Production audit claim hygiene: counts-not-booleans, explicit empty Money-Ready state, fix frozen ghost note, strict-JSON gate.
4. Local secondary dashboard fixes **only after** dashboard-authority is answered.

**Pause (human-gated):** row/combo deletion, combo fabrication, bulk cron/concurrency sweep, sports rename, prediction-market promotion/persistence, any real-money sizing, re-adding the audit-dashboard push trigger.

## 5. Left undone / needs owner

- No production remediation applied; every change requires human approval.
- Open decisions: B2/D14 dashboard authority; D3 `db_freshness.json` + doc sweep; D4 sports API check/retire; D6 cron pilot scope; Q2 `hub/data/*` liveness.
- Validator extras V4/V8/V9 are now folded into `folderframework-v3/tools/swarm/swarm_librarian.py` (`--repo-root` enables V4 path resolution); `HANDOFF.md` added to the top-level allowlist.
- Optional: publish one merged cross-domain package at `AGENT_FOLDERFRAMEWORK/2026-11-16-SWARM-MERGED/07_final_review4/`.

## 6. COMS

Seat registered: `inbox/gx10-c9b9/folderframework-v2/folderframework-v2`. Subscription active (own inbox + worktree `all` + `mentions/all`). Summary posted to `inbox/gx10-c9b9/folderframework-v2/all`.