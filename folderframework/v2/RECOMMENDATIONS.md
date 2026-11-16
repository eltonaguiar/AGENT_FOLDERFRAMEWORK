# Recommendations

Order is evidence weight, then reversibility. None of this is applied.

## Do now (docs and labels only)

1. Keep three artifact trees. Do not squash them.
   - Claims about the production audit ledger: `folderframework/2026-11-16-SWARM/07_final_review4/`.
   - GH Actions safety: `folderframework-v4/07_final_review4/`.
   - Protocol and librarian: `folderframework-v3/`.
2. Treat v2's file:line list as a local-dashboard bug list, not as the live `/audit` plan.
3. Any future banner must quote `total_ghost_rows`, `trading_picks.open_count`, and `trading_picks.active_count`. Do not quote `ok` or `banner_should_show`.
4. Money-Ready copy must say `0` classes ready while `summary.money_ready` is `[]`. COMMODITY stays WATCH.

## Do after a human accepts the display-only scope

5. On `dashboard/generate_dashboard.py:15` and `:30`, stop painting exact zero as `negative`. Use a third class until decision D1.
6. Remove or label the hardcoded `win_rate: 55.0` and `sharpe: 0.3` in `enhanced_audit_dashboard.py:107-109`. Do not "fix" line 103 again.
7. Leave `audit_systems.py:35` alone until D1. Zero-as-loss is a defined choice, not a proven bug.

## Do not do in this swarm

8. Do not generate winning combos or force `active_systems > 0` to satisfy v2's charter.
9. Do not delete ghost rows or open picks.
10. Do not persist Kalshi/Polymarket feeds or leave shadow.
11. Do not apply v4's cron stagger, sports disable, or `db_freshness.json` deletion until those decisions are explicit.
12. Do not `git add .github/workflows/` from a worktree that is behind `origin/main`.
13. Do not re-add the `audit-dashboard.yml` push trigger.

## If one tool is kept

Use `folderframework-v3/tools/swarm/swarm_librarian.py` for scaffold/collect/index. Leave `folderframework/2026-11-16-SWARM/tools/swarm_librarian.py` as the smaller init-only script. Do not fork a third copy.
