# 2026-11-19 — kilo → COMS (audit3 G8/DSR/family gates + forward ingest)

**From:** kilo (`vanilla-handsaw-audit3` worktree, host `gx10-c9b9`)
**To:** auditpage / auditpage-v4 / review-main agents, and `mentions/all`
**Durable detail:** `COMS_HANDOFF_2026-11-19_AUDIT3_G8_SCOPE.md` at the root of
`eltonaguiar/findtorontoevents_antigravity.ca`, branch **`fix/audit3-alpha-scope`**
(commits `b9dd4378e65`, `3844a4e34e2`, `7ba21e907cd`). Not pushed.
**Review evidence:** `antigravity_review_Nov192026/10_KILO_VANILLA_HANDSAW/VERIFICATION_P0P1.md`.

## Why handoff

Verifying commit `3dfa66e` ("P0/P1 correctness") found three of its five claims did
not meet their own acceptance criteria, plus one bucket that skipped every gate and
a forward ledger with no scheduled writer. Fixes are committed locally on the
branch above; the next agent should review, rebase, regenerate the ledger, and open
a PR. **Do not push to `main` directly** — it changes published verdicts.

## What changed (one line each)

1. **G8 alpha scope** — strategy cells now need *strategy-level* selection alpha;
   a class number is recorded as `class_proxy` and demotes.
2. **DSR multiplicity** — PROVEN pays the 658-trial registry null; CANDIDATE uses
   bucket width so the forward queue is not emptied.
3. **require_alpha** — a missing alpha sidecar demotes `PROVEN_T2` instead of
   silently fail-opening on the published path.
4. **Alpha coverage floor** — `alpha_n >= max(20, 0.5 × cell.n)`; `alpha_n` published.
5. **Direction/window hygiene** — BUY→LONG (was `"?"`, inverted benchmark);
   `issued_at == closed_at` rows rejected (fabricated zero benchmark).
6. **Source families gated** — they previously skipped BH/DSR/forward/harm entirely.
7. **Forward ingest scheduled** — new 6-hourly workflow runs `--apply`, pins
   `ref: main`, fails on 0 admissible rows, and reports cells with no forward path.

## Merge checklist

```
git log --oneline 3dfa66e..fix/audit3-alpha-scope   # 3 commits expected
python3 -m pytest tests/test_audit3_tribunal.py tests/test_audit3_expectancy_gates.py \
  tests/test_audit3_edge_hunt.py tests/test_audit3_selection_alpha.py \
  tests/test_forward_observations_ingest.py tests/test_audit3_cost_basis.py -q   # 79 passed
```

Then regenerate `audit3_ledger.json` with `--alpha` and report the delta in
`n_proven` / `n_candidate` / `selection_alpha.gate.*` before pushing.

## Open, deliberately

P0-3 at-issue stamping (writer change, not a gate); symbol-level alpha; forward
coverage is one hypothesis wide (H-119); alpha vs tribunal row-set mismatch;
blocklist fail-open in `forward_validator.py`; 3 pre-existing order-dependent
slippage tests.

*No strategy, threshold value, or honest-verdict policy was changed.*
