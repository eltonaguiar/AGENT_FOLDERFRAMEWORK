# IMPLEMENTATION_STEPS

Do not start until a human accepts this plan. Each step has a rollback that is "revert the commit". No data deletes.

## Step 1 — Claim source of truth

File: the audit page or generator that prints ghost-row and open-bloat banners (confirm the writer before editing; candidates are `audit_trail/dashboard_generator.py` and `audit_dashboard/`).

Change: read `checks.ghost_rows.data.total_ghost_rows`, `checks.open_bloat.data.trading_picks.open_count`, and `checks.open_bloat.data.trading_picks.active_count`. Do not print "0" when `ok` is true.

Rollback: revert the display commit. JSON files are untouched.

## Step 2 — Money-Ready empty state

Files: `audit_dashboard/pick_funnel.html`, `audit_dashboard/strategy_perf_by_class.html`, and any script that injects `nc-nodata` when `summary.money_ready` is `[]`.

Change: render "0 classes money-ready" plus per-class verdict, wr, pf. Keep the existing sizing lock. Do not add classes to `money_ready`.

Rollback: revert the template commit.

## Step 3 — Live check before any workflow edit

Command (read-only):

```bash
curl -fsS https://findtorontoevents.ca/audit/data/money_ready_verdict.json | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["generated_at"], d["summary"])'
```

If the live `summary.money_ready` is `[]` and `generated_at` is recent, skip workflow edits.

Rollback: none. Read-only.

## Step 4 — Snapshot call-site (only if Phase C is approved)

Files: `audit_trail/universal_pick_resolver.py:934`, `audit_trail/dashboard_generator.py:5493`.

Change: identify the live caller. Make the unused copy call the live one, or delete it after a test imports the live one. Keep prediction markets shadow. Do not add Kalshi/Polymarket persistence.

Rollback: revert the dedup commit. Do not migrate historical PnL in the same change.

## Explicit non-steps

- No `DELETE` against ghost rows or open picks.
- No edit to real-money gates.
- No force-push.
- No commit of secrets or full dumps.
