# 01 — Peer review (evidence-linked)

Reviewed against `eltonaguiar/findtorontoevents_antigravity.ca` working tree at branch
`folderframework-v4` (repo is huge; both `dashboard/` and `audit_dashboard/` exist).

---

## A. Peer `folderframework/` — AUDIT claim hygiene (pilot)

**What it does well (I agree):**
- Correctly separates boolean gates from counts: `checks.ghost_rows.ok == true` while `data.total_ghost_rows == 22947`. That is the single most important claim-hygiene point and it is evidence-linked to `audit_dashboard/data/db_health.json` (`generated_at 2026-11-16T01:29:16Z`).
- Correctly distinguishes "Money-Ready is empty by verdict" (`summary.money_ready == []`) from a "No data" tile (`cleanup_dashboard.py` emits `nc-nodata`). This matches the code: `audit_trail/dashboard_generator.py:6071` reads `audit_dashboard/data/money_ready_verdict.json`; `audit_trail/quality_gates.py` also references it.
- Non-destructive stance (no row deletes) — same spirit as my "docs only, no workflow edits."
- Prediction markets held at shadow (PBO 0.603); my audit touches PM steps (`audit-dashboard.yml` lines 117–121) but recommends no change. **Aligned.**

**Where I extend it (my GH Actions work fills its self-declared gap):**
- Its `04_final_review` and `05_final_reviewv2` both say **"GHACTIONS items stay investigative until a run log is attached"** and its Phase B gate is *"inspect `audit-dashboard.yml` deploy output."* My `03_DONE/GHACTIONS/.../site_impact_audit.md` §1 is that deploy inventory (54 writers, 13 targeting `/audit`; `audit-dashboard.yml` = primary, hourly, `cancel-in-progress: false`, 115-min timeout). **Its Phase B prerequisite now exists.**
- Its residual risk *"duplicate snapshot function may mean a fix lands in the unused copy"* (about `_snapshot_prediction_market_entry`) is a **code-import** question, not a workflow question — my push-chain audit does not trace Python imports, so I **cannot** close it. Flagged as a joint open item (see `03_*` Q3).

**Where I disagree / caution:**
- Its Phase B says *"workflow/deploy only if Phase A live check fails."* My audit shows the deploy surface is **already** risky independent of Phase A: `deploy-competition-to-site.yml` has `/audit` in its push `paths:` and **no `concurrency:` group** (my RC8). So "only if Phase A fails" under-states a standing hazard. Recommend adding my Step 9 (concurrency group on that deployer) to its plan regardless.

---

## B. Peer `folderframework-v2/` — AUDIT bug locations (file:line)

**Verdict: the only peer that delivered concrete file:line bugs (matches the earlier "exact bug locations" ask). Paths are REAL — I verified every one exists. But it violates the evidence rule (no SHA, no command, no run output) and ~half the bugs are outside the live `/audit` path.**

I re-read each cited line in the working tree:

| # | v2 claim | Verified in code | Correct? | Live-path? |
|---|---|---|---|---|
| 1 | `dashboard/generate_dashboard.py` L15 & L30 — `> 0` misclassifies break-even as negative | L15 `pnl_class = "positive" if pick["unrealized_pnl_pct"] > 0 else "negative"`; L30 same for `total_unrealized_pnl` | **Yes, real** | Runs only in `live_tracker.yml` (repo-committed `dashboard/index.html`), **not** the FTP `/audit` |
| 2 | `audit_systems.py` L35 — zero-PnL trades counted wrong | L35 `wins = sum(... > 0)`; L36 `losses = sum(... <= 0)` → zero counts as loss | **Yes, real** | `audit_systems.py` is run by **no** workflow (manual only) |
| 3 | `enhanced_audit_dashboard.py` L103 — total PnL aggregates wrong for missing fields | L103 already does `(... ) or 0` with comment *"2026-06-04: coalesce explicit None"* | **Partly stale** — the None bug is already fixed; the real latent bug there is hardcoded `'win_rate': 55.0` | Run by **no** workflow (manual only) |
| 4 | `hub/data/integrated_dashboard.json` — no active systems | data-state, not code | Not a code bug | `hub/` not referenced by `audit-dashboard.yml` |
| 5 | `hub/data/winning_combos.json` — no winning combos | data-state | Not a code bug | same |

**What this means:** v2's #1 and #2 are genuine correctness bugs worth fixing (credit due), but they live in the `live_tracker.yml` dashboard and in a manual script — **not** the primary `/audit` surface that `folderframework`'s plan and my site-impact audit target. #3 is partly fixed and misses the actual hardcoded-`win_rate` bug. Before anyone implements v2's list, confirm **which** dashboard the user actually reads (see D1).

---

## C. Peer `folderframework-v3/` — scaffold + tooling

- Its `07_final_review4/*.md` are **unfilled templates** (PLAN.md is the literal template; EVIDENCE_INDEX/FILES_TO_TOUCH/IMPLEMENTATION_STEPS/TESTING_PLAN likewise). So there is no content to review for correctness.
- Its real contribution is `tools/swarm/swarm_librarian.py` (stdlib `scaffold`/`collect`/`index`) and the dated scaffold. **Recommendation:** adopt it to regenerate consistent indexes across all four folders — my folder used a manual structure; standardizing reduces drift.

---

## D. Peer `folderframework-v4/` — mine (self-review)

- **Strengths:** every claim is tied to a SHA/command/file; two retractions honored; the stale-fork trap and untracked-`lint.yml` hazard are captured; revert runbook is copy-pasteable.
- **Gaps I own:** (a) base SHAs are non-durable (main moves ~60 s) — a fresh run will differ; (b) I did not trace Python import call-paths (so I can't close the `_snapshot_prediction_market_entry` question); (c) I did not pull a *fresh* Actions run log for the historical 404/Infinity claims (I only inventoried triggers).

---

## E. Cross-cutting reconciliation (the payoff)

| Apparent contradiction | Resolution | Evidence |
|---|---|---|
| `folderframework`: "money_ready is []" vs `v2`: "index.html shows Money-Ready: No data" | **Both true — different dashboards.** Live `/audit` uses `audit_trail/dashboard_generator.py` (verdict `[]`); `v2` read `dashboard/index.html` from `live_tracker.yml` (`generate_dashboard.py`). | `audit-dashboard.yml` runs `audit_trail.*`; `live_tracker.yml:41` runs `dashboard/generate_dashboard.py`; `dashboard_generator.py:6071` reads `money_ready_verdict.json` |
| `folderframework`: "audit-dashboard.yml deploy output unknown" vs `v4`: "deploy surface inventoried" | My `site_impact_audit.md` supplies it. | `site_impact_audit.md` §1 |
| `folderframework` defers GHACTIONS vs `v4` delivers GHACTIONS | Complementary, not conflicting. | this folder |