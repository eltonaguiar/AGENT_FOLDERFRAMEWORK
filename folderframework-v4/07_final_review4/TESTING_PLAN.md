# TESTING_PLAN — GH Actions remediation

Two layers: (1) static verification that needs only `git`, (2) live verification that needs the repo +
GitHub. Every step in `IMPLEMENTATION_STEPS.md` maps to at least one check here.

---

## 1. Pre-push static checks (run before ANY commit touching workflows)

```bash
git fetch origin main

# T1 — workflow delta must be empty (0 rows). Non-zero = STOP.
git diff --name-status HEAD origin/main -- .github/workflows/ | tee /tmp/wf_delta.txt
test ! -s /tmp/wf_delta.txt && echo "PASS: no workflow delta" || { echo "FAIL: workflow delta present"; cat /tmp/wf_delta.txt; }

# T2 — the 90-minute timeout must be present at job level.
grep -n "timeout-minutes" .github/workflows/dynamic-alpha-engine.yml   # expect a line with 90 (line 115)

# T3 — file count parity (catches resurrection of the 9 deletions).
A=$(git ls-tree -r --name-only origin/main -- .github/workflows | wc -l)
B=$(git ls-tree -r --name-only HEAD        -- .github/workflows | wc -l)
echo "main=$A head=$B"; test "$A" = "$B" && echo "PASS: counts match" || echo "FAIL: resurrect/drop"
```

## 2. Per-step acceptance tests

| Step | Test | Expected |
|---|---|---|
| 1 Publish | folder exists on `AGENT_FOLDERFRAMEWORK/main` | 12+ files under `folderframework-v4/` |
| 2 Guardrail | `grep` for "never `git add .github/workflows/`" in contributor docs | 1+ hit |
| 3 Timeout | `grep -n "timeout-minutes: 90" dynamic-alpha-engine.yml` | hits line 115 |
| 4 Stagger | recompute `zlib.crc32(name)%60` per file; compare to file | identical; no minute-0 pile > threshold |
| 5 Concurrency | `grep -L "concurrency:"` over the 192 target files | returns empty for the batch |
| 6 Linter | run the stagger linter on the tree | exit 0 |
| 7 DB freshness | `git grep -l db_freshness -- '*.php' '*.js' '*.html'` | empty (no consumer) |
| 8 Sports | load `/live-monitor/sports-betting.html`; check banner | "retired as of <date>" visible |
| 9 Deploy race | `grep -A2 "^concurrency:" deploy-competition-to-site.yml` | group + `cancel-in-progress: false` |

## 3. Live verification (needs GitHub)

```bash
# L1 — confirm main's workflow count from the API (not the local clone).
gh api repos/eltonaguiar/findtorontoevents_antigravity.ca/contents/.github/workflows \
  --jq 'length'

# L2 — confirm the timeout blob on main.
gh api repos/eltonaguiar/findtorontoevents_antigravity.ca/contents/.github/workflows/dynamic-alpha-engine.yml \
  --jq '.content' | base64 -d | grep -n "timeout-minutes"

# L3 — confirm the live /audit dashboard still renders (primary writer sanity).
curl -fsS -o /dev/null -w "%{http_code}\n" https://findtorontoevents.ca/audit/data/dashboard_data.json
```

## 4. Regression checklist (human)

- [ ] `dynamic-alpha-engine.yml` still at `timeout-minutes: 90` (no churn regression).
- [ ] The 9 dedup deletions remain deleted on `main` (no silent resurrection).
- [ ] `/audit` dashboard loads and `dashboard_data.json` returns 200.
- [ ] No new workflow appears in `.github/workflows/` from a stale-fork stage.
- [ ] Cron changes did not delete any `github.event.schedule` branch (17 multi-cron files intact).
- [ ] Sports page banner reads as historical (if Step 8 applied).

## 5. Negative tests (must NOT regress)

- `git grep -n "deploy-competition.yml" origin/main -- .github/workflows` → no such file (the retracted "2-min deploy" claim).
- Two-axis push hazard count == 0 (`branch_trigger_audit.md` §2).
- No file both lacks `branches:` and lacks `paths:` under `on: push`.