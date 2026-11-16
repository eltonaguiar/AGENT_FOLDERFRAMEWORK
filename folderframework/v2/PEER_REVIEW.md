# Peer review — folderframework vs v2, v3, v4

Base: AGENT_FOLDERFRAMEWORK `22a0d67`. Source worktree `folderframework` @ `db4cc06ed82`. I re-read the cited lines. I did not fetch the live site.

## What I agree with

- **v3 charter S1/S2 match my counts.** Ghost rows are 22947, not a clean boolean. Open vs active is 91705 vs 21 in `audit_dashboard/data/db_health.json` (`generated_at=2026-11-16T01:29:16Z`). v3 wrote 22,947 and 91k vs 21 as the claim to verify. Same facts.
- **v3 non-goals are correct.** No real-money sizing. No mass workflow deletion. No merge of final_review4 without a human. Do not re-add the `audit-dashboard.yml` push trigger.
- **v3 prediction constraint matches the standing decision.** Shadow only (PBO 0.603). Copy trading rejected. I keep that.
- **v2 display bug is real, on a different surface.** `dashboard/generate_dashboard.py:15` and `:30` use `> 0` else `negative`, so zero unrealized or realized PnL renders red. `audit_systems.py:35` counts only `> 0` as a win, so a zero is a loss (`:36`).
- **v2 hub files are empty as claimed.** `hub/data/integrated_dashboard.json` has `active_systems=0`. `hub/data/winning_combos.json` has `total_found=0`.
- **v4 is the GHACTIONS record.** I do not re-audit the fleet. Adopt: no whole-fleet push hazard on the SHA they pinned; do not `git add .github/workflows/` wholesale; do not resurrect deleted workflows; do not commit untracked `lint.yml`; minute-0 cron pile-up is a later, reversible change.
- **v3 librarian is the better tool.** `folderframework-v3/tools/swarm/swarm_librarian.py` can scaffold, collect, and index. Mine only inits folders and lists markdown. Use v3's CLI if one librarian is chosen. Do not merge the scripts in this pass.

## What I disagree with

- **v2 success criteria 1, 3, and 5 are not hygiene.** Requiring Battleground WR ≥ 40%, `winning_combos.json` `total_found > 0`, and "J Bravo FVG" as a prop-firm winner (Sharpe ≥ 1.0, WR ≥ 65%) forces a research result. `money_ready_verdict.json` at `2026-11-16T01:44:34Z` has `summary.money_ready=[]`. Promoting a named strategy from an empty verdict violates the real-money gate. Explanation-or-empty is acceptable. A manufactured winner is not.
- **v2 bug 3 is already partly fixed, and the worse bug is next to it.** `enhanced_audit_dashboard.py:103` already coalesces missing PnL (`2026-06-04` comment). Lines 107–109 still hardcode `win_rate: 55.0` and `sharpe: 0.3`. That is the display lie. v2 did not cite it.
- **v2 "Money-Ready: No data" is the wrong page unless proven otherwise.** The cited generator writes `dashboard/index.html` from `dashboard/live_picks.json`. The production audit page is `audit_dashboard/` served at https://findtorontoevents.ca/audit/. Fixing the local generator does not fix the live audit panel.
- **v3 S3 as written can be misread.** "Money-Ready panel renders live data — no No data" is satisfied by an explicit empty verdict, not by inventing a ready class. Snapshot: empty list, COMMODITY is WATCH (wr 0.4017, pf 1.0256), not ready.
- **v3 Phase-5 files are not a plan.** `folderframework-v3/2026-11-16-SWARM/07_final_review4/PLAN.md` and `EVIDENCE_INDEX.md` are blank templates. Do not treat them as findings.
- **v4 remediation is not approved work.** Cron stagger across 192 files, deleting `audit_dashboard/data/db_freshness.json`, and renaming sports workflows are proposals. Their own plan says nothing was applied. I do not adopt Phase B/C as decided.
- **My own first drop was incomplete.** `folderframework/2026-11-16-SWARM/06_final_review3/SYNTHESIS.md` said no peers existed. That was true at `05e6e8b` and false after `22a0d67`. This v2 folder is the correction. I am not rewriting the earlier files.

## Changes to my own plan

1. Split surfaces. Production claims stay on `audit_dashboard/data/db_health.json` and `money_ready_verdict.json`. Local `dashboard/` and `hub/data/` are a second track.
2. Add the zero-PnL badge as a low-risk display fix, but do not call break-even a win until a human picks the class.
3. Add the hardcoded 55% / 0.3 Sharpe as a higher-priority lie than the None-coalesce on line 103.
4. Block any workflow edit with v4's precondition: `git fetch origin main` and an empty `git diff --name-status HEAD origin/main -- .github/workflows/` before staging.
5. Do not start ghost-row deletion, combo generation, or prediction-feed persistence.

## Risk

| Fix | Risk | Why |
|-----|------|-----|
| Label ghost/open/active from `db_health.json` data fields | Low | Read-only numbers already in the file |
| Explicit empty Money-Ready state | Low | Verdict list is already empty |
| Zero-PnL CSS class on `dashboard/generate_dashboard.py` | Low | Local generator; confirm it is not the live audit page first |
| Counting zero as a win in `audit_systems.py` | Med | Changes WR math, not just color |
| Generating winning combos to satisfy v2 S3 | High | Manufactures a success metric |
| v4 cron/concurrency sweep | Med | Behavioral, large diff, stale-fork trap |
| Deleting `db_freshness.json` or disabling sports workflows | Med | Decision-gated in v4; not re-verified here |
