# TESTING_PLAN.md — how every change is verified

> Template. Map each implementation step to at least one automated check + one live check.

## Unit / script tests
| Step | Test | Command | Pass criteria |
|------|------|---------|---------------|
| 1 |  |  |  |

## Live verification
| Step | Check | Command / URL | Expected |
|------|-------|---------------|----------|
| 1 | dashboard JSON parses strictly | `curl -s https://findtorontoevents.ca/audit/data/dashboard_data.json \| python3 -c "import json,sys; json.load(sys.stdin)"` | exit 0 |

## Regression checks
- Ghost-row count: dashboard figure == `db_health.json` figure (S1)
- Money-Ready panel renders data on live page (S3)
- Prediction-market badge/status unchanged or explicitly shadow (S5)

## Manual checklist for human reviewer
- [ ] All automated checks green
- [ ] Live URLs verified within the last hour
- [ ] Rollback path confirmed for every merged step
