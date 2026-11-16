# 08 — Final verdict: what to implement, what to pause (folderframework-v3)

**State as of 2026-11-16T06:33Z**
- All four round-2 peers are now complete: `folderframework`, `folderframework-v2`, `folderframework-v4`, and `folderframework-v3` (this worktree).
- This worktree's round-2 drop is on `AGENT_FOLDERFRAMEWORK/main` at commit `a9deb2c`.
- Source-repo worktree `findtorontoevents_antigravity.ca/.kilo/worktrees/folderframework-v3` is clean at `db4cc06ed82`.
- `folderframework-v3/2026-11-16-SWARM/` passes `swarm_librarian.py validate` with 0 errors, 0 warnings.

This document replaces the earlier "next actions" draft with the consolidated **final verdict** after the completed peer round.

---

## Executive summary

Implement the low-risk, display-only fixes and the framework canon now. Pause every plumbing change that needs a human decision. Reject mass-destructive actions and anything that violates existing project constraints. Track research items separately so they do not block the implementable work.

---

## 1. Implement now (P0 — low risk, high trust, peers converged)

| # | Change | Location | Owner | Why peers converged |
|---|--------|----------|-------|---------------------|
| I1 | **Ratify the swarm framework canon** | `AGENT_FOLDERFRAMEWORK` forward-only | human / coordinator | v1, v2, v4, and external review all adopt v3's dated `YYYY-MM-DD-SWARM/` root, `swarm_librarian.py`, `AGENT_PROMPT.md`, and YAML front-matter. Existing peer folders are grandfathered, not rewritten. |
| I2 | **Fix the ghost-row "0" lie** | `audit_dashboard/dashboard_enhancements.js:829-833` | dev | The live count (22,947) renders correctly; the "0" is a stale hardcoded 2026-05-31 remediation sentence inside the same banner. Replace with live-driven text. *Found by v3.* |
| I3 | **Render Money-Ready empty state truthfully** | `audit_trail/dashboard_generator.py` or the consumer of `money_ready_verdict.json` | dev | Verdict is `[]` (0 classes ready, n=10 scanned), COMMODITY is WATCH. Never render "No data" or fabricate a class. |
| I4 | **Neutral break-even PnL class** | `dashboard/generate_dashboard.py:15,30` and `audit_systems.py:35-36` | dev | 22/24 live picks have `unrealized_pnl_pct == 0`; current `> 0` logic paints them red. Add a neutral class; do **not** change win/loss math in the same commit. |
| I5 | **Normalize BUY/SELL side badges** | `dashboard/generate_dashboard.py:14` | dev | Live sides are `{BUY:6, LONG:4, SHORT:11, SELL:3}`; non-`LONG` renders as SHORT, mis-badging 9 picks. Add `normalize_side()`. *Found by v2, verified by v3/v4.* |
| I6 | **Remove or label hardcoded WR/Sharpe** | `enhanced_audit_dashboard.py:106-109` | dev | Hardcoded `win_rate: 55.0` / `sharpe: 0.3` is a display lie. Do **not** "re-fix" L103 (already coalesced in 2026-06-04). *Found by v1/v4.* |
| I7 | **Add GH Actions push-safety rule to `AGENTS.md`** | source-repo `AGENTS.md` | dev | Never stage `.github/workflows/` wholesale from a worktree that may be behind `origin/main`. v4's stale-fork trap (88k ahead / 15 behind) makes this the highest-leverage guardrail. |
| I8 | **Land `/audit` deploy concurrency group** | already done in `20f6e1cdad1`; convert to regression watch only | dev | v4's Step 9 and v3's verification confirm it is live on `deploy-competition-to-site.yml` and `deploy-fte-index.yml`. No code change needed; add a watch in `TESTING_PLAN`. |

### Phase-A PR grouping
- **Single PR** for I2–I6 (display-only; no row deletions, no math changes).
- **Separate PR** for I7 (docs/safety) so it is not held up by dashboard authority questions.

---

## 2. Pause / decision-gated (do not implement until the named decision is made)

| # | Item | Decision needed | Why it is paused | Peers' stance |
|---|------|-----------------|------------------|---------------|
| P1 | `audit_dashboard/data/db_freshness.json` deletion + doc sweep | Human / D3 | Zero consumers verified, but it is a committed file with historical doc refs; needs explicit approval. | v4 proposed; v1/v3 verified no consumers. |
| P2 | Cron minute-0 stagger pilot | Human / D6 | Count bases drifted across v4's own files (356/358/373); must re-pin at fresh SHA before touching 15 files. | v4 designed; v3 recommends pilot-only. |
| P3 | Concurrency backfill on ~192 workflow files | Human / D6 | FTP uploads must never be cancelled mid-flight; needs batching and dual-mode-first logic. | v4 proposed; v3 says batches of ~20 with fresh SHAs. |
| P4 | Sports retire-with-banner + `.yml.disabled` rename | Human / D4 + API check | `disabled_manually` is GitHub-side, invisible in git; one `gh api` pass required first. | v4 C1; v3 says verify before acting. |
| P5 | Bulk branch pruning (Tier 1: 102 idle ≥90d) | Human / D5 | Project correction `gha_stale_workflow_count` warns against artifact-driven mass actions; needs its own dated swarm. | v4 Tier 0–1; v3 says Tier 0 only (7 merged branches) now, bulk deferred. |
| P6 | v4 folder migration into dated-SWARM | Human / D2 | Copy-with-SHA is safe, but unilateral moves violate protocol; also peers cite v4 paths. | v1 says copy-not-move; v4 held on D8; v3 agrees copy-if-asked. |
| P7 | Untracked `.github/workflows/lint.yml` | Human / D6-v4 | As-is it has unbounded `push:` and untracked deps; committing it red on every push. | v4 D6: rewrite or leave untracked. |
| P8 | Agent-communication board (`iac`) pilot | User constraint `be4e3dd` | Kilo’s native board + `AGENT_FOLDERFRAMEWORK` already cover this swarm. Only justified if non-Kilo agents (Ollama, OpenClaw, Hermes) on this machine need sleep-until-mentioned wakeup. | v3 and v4 independently converged on `iac` as the closest match; smoke test verified. |

---

## 3. Reject / explicitly out of scope

| # | Item | Reason |
|---|------|--------|
| R1 | Mass-delete 22,947 ghost rows or 91,705 open picks to "make the number zero" | Hides duplicates instead of labeling them; no tested rollback; violates non-destructive consensus. |
| R2 | Persist Kalshi/Polymarket emitter output | Conflicts with project decision: prediction markets stay shadow (PBO 0.603); copy-trading rejected. |
| R3 | Re-add the `audit-dashboard.yml` push trigger | 2026-05-19 cancel-cascade incident; hourly cron at :10 is sufficient per project correction. |
| R4 | Any real-money sizing | `real_money.html` Lopez de Prado gates (DSR>0.95, PBO<0.05, WFE>60%, live-Sharpe>0.5, n≥100) + explicit human greenlight required. |
| R5 | Rewrite peers' folders in `AGENT_FOLDERFRAMEWORK` to match canon | Violates the framework's own no-edit-others rule; canon applies forward only. |
| R6 | Treat `dashboard/index.html` as the canonical `/audit` surface until proven | `live_tracker.yml:41-44` may overwrite it from `alpha_engine/live_dashboard.html`; v1/v3/v4 all flag this as unverified. |
| R7 | Apply v2's `>= 0` win-count semantics **and** neutral class in the same commit | v1 correctly notes these are different fixes; neutral is display-only, `>=0` would count break-even as a win. Do not ship both. |

---

## 4. Research / separate track (does not block Phase A)

| # | Item | Question it closes | Suggested executor |
|---|------|--------------------|---------------------|
| F1 | Runtime-state API pass | Are the 5 sports workflows `disabled_manually`? What are recent `audit-dashboard.yml` conclusions? | Evidence agent, 30 min, output to `03_DONE/GHACTIONS/`. |
| F2 | Live-surface census of `dashboard/` scripts and `hub/data/*.json` | Who invokes `generate_dashboard.py`, `enhanced_audit_dashboard.py`, `audit_systems.py`? Who reads `hub/data/integrated_dashboard.json` / `winning_combos.json`? | Scout agent; grep + crontab check. |
| F3 | Recompute v4 count bases at one pinned SHA | Resolve 356/358/373 workflow count drift and 189/190 minute-0 split before any cron pilot. | Evidence agent; commit the recomputation script. |
| F4 | Prediction-market snapshot contract test | Which `_snapshot_prediction_market_entry` copy runs on the live page? Unit-test contract-price semantics at both call sites before dedup. | Future PREDICTION swarm. |
| F5 | Money-Ready live-HTML wording | What text does a human actually see for `money_ready: []`? | Evidence agent with curl/Playwright screenshot. |
| F6 | v4 "88,367 ahead / 15 behind" clone check | Rule out repo-integrity incident vs shallow-clone artifact. | v4 owner or fresh full clone. |

---

## 5. Human blockers (answer these before any Phase-B work)

1. **B1 — Ratify canon?** Yes/no on dated-SWARM + `swarm_librarian.py` + `AGENT_PROMPT.md` forward-only.
2. **B2 — Which audit dashboard is authoritative?** (a) live `/audit` from `audit_trail/dashboard_generator.py`; (b) repo `dashboard/index.html` from `live_tracker.yml`; (c) legacy manual scripts. This gates whether v2's `dashboard/` fixes matter to the public site.
3. **B3 — Delete `db_freshness.json`?** Yes/no on file deletion + doc sweep.
4. **B4 — Sports retire/banner/rename?** Yes/no after F1 API check.
5. **B5 — Cron stagger pilot?** Yes/no on piloting the worst tier (`0 */2`, 15 files) with 24 h observation.

---

## 6. Guardrails (non-negotiable for any implementer)

- **No row deletions** in any display-only pass.
- **No `git add .github/workflows/`** wholesale.
- **No force-push** to `AGENT_FOLDERFRAMEWORK/main` or `findtorontoevents_antigravity.ca/main`.
- **No prediction-market promotion** or emitter persistence.
- **No real-money sizing** without greenlight and all gates clear.
- **No editing of peer folders** in `AGENT_FOLDERFRAMEWORK`.

---

## 7. Success criteria for close-out

- [ ] Canon ratified (human yes).
- [ ] Phase-A PR (I2–I6) drafted and ready for human review.
- [ ] Push-safety PR (I7) drafted.
- [ ] F1 runtime-state pass completed and committed with front-matter.
- [ ] B2 answered; if `dashboard/index.html` is not authoritative, deprioritize or close v2's dashboard bugs.
- [ ] A single merged final plan (or master index) exists in one `07_final_review4/` with domain sections.

---

*Round 2 is complete. The swarm's job is done; implementation authority now rests with the human.*
