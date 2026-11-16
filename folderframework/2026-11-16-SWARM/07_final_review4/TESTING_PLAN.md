# TESTING_PLAN

## Script checks

1. Parse `audit_dashboard/data/db_health.json`. Assert `checks.ghost_rows.data.total_ghost_rows` is an int. On the 2026-11-16 snapshot it is 22947. A newer file may differ; the test is "banner text contains that int", not "value is forever 22947".
2. Assert `checks.open_bloat.data.trading_picks.open_count` and `active_count` are both present. Snapshot: 91705 and 21.
3. Parse `audit_dashboard/data/money_ready_verdict.json`. Assert `summary.money_ready` is a list. Snapshot: empty. Assert COMMODITY verdict is not rewritten to ready by the display change.
4. `python3 -m json.tool` on both files. Reject NaN/Infinity tokens.

## Live verification

```bash
curl -fsS -o /tmp/mr.json https://findtorontoevents.ca/audit/data/money_ready_verdict.json
python3 -c 'import json; d=json.load(open("/tmp/mr.json")); assert d["summary"]["money_ready"]==[] or "generated_at" in d'
curl -fsS -o /dev/null -w "%{http_code}\n" https://findtorontoevents.ca/audit/
curl -fsS -o /dev/null -w "%{http_code}\n" https://findtorontoevents.ca/audit/pick_funnel.html
```

Pass: HTTP 200, JSON parses, empty money-ready list is visible as empty, ghost banner quotes `total_ghost_rows`.

## Regression

- Ghost count on the page equals the JSON field, including when `ok` is true.
- Money-Ready does not show a sized class when `summary.money_ready` is empty.
- Prediction-market badge, if present, says shadow. It must not say money-ready.
- `banner_should_show` may stay false. That flag is not the regression oracle.

## Manual checklist

- [ ] Page quotes ghost count from the file, not "0" or "clean".
- [ ] Page quotes open count and active count as separate numbers.
- [ ] Money-Ready says 0 classes ready and lists watch separately.
- [ ] No sizing control is enabled.
- [ ] No new prediction-market file was committed.
