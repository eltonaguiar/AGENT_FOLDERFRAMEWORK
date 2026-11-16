# v2 — Cross-review of folderframework-v4 against peer worktrees

**Author:** `folderframework-v4`
**Date:** 2026-11-16
**Inputs reviewed (all on `eltonaguiar/AGENT_FOLDERFRAMEWORK` main):**
- `folderframework/` — pilot: AUDIT claim hygiene (full phased 04→07, filled).
- `folderframework-v2/` — AUDIT bug locations (file:line report, single pass).
- `folderframework-v3/` — framework scaffold + `swarm_librarian.py` (templates, unfilled).
- `folderframework-v4/` — mine: GH Actions audit.

**Purpose:** review my GH Actions work against peers, then state final recommendations,
decisions required, open questions, and further research.

## Contents
| File | What |
|---|---|
| `01_PEER_REVIEW.md` | Peer-by-peer review with evidence; where I agree/disagree/extend |
| `02_FINAL_RECOMMENDATIONS.md` | Final recommendations + decisions required from the human |
| `03_OPEN_QUESTIONS_AND_RESEARCH.md` | Ambiguities, open questions, further research |
| `04_PEER_RECONCILIATION.md` | Reconciliation with `folderframework/v2/`'s review of my v4 (converged + added facts) |
| `05_FRAMEWORK_STRUCTURE_REVIEW.md` | External meta-review incorporated: structural/generic/enforcement gaps + fixes |
| `06_FINAL_FINDINGS_ROUND2.md` | **Round-2 capstone**: per-agent status, convergence scorecard, merged decisions (B1–B4/S1–S4), v3 re-check |
| `07_ACTION_PLAN_NEXT_STEPS.md` | Sequenced next-steps plan (phases 0–4, owners, risk, done-when) |
| `08_FINAL_VERDICT.md` | **Final verdict**: IMPLEMENT (🟢 I1–I12) / PAUSE (🟡 P1–P7) / REJECT (🔴 R1–R9) / OBSOLETE (⚪ O1–O2) |
| `09_COMMUNICATION_FRAMEWORKS.md` | Research: Antigravity `/swarm` (verified) + 6 blackboard repos evaluated; recommendation (iac + verifier/monitor) |

## TL;DR
1. **Not competing drafts — complementary slices.** `folderframework`/`v2` = AUDIT+DB, `v3` = tooling, `v4` (me) = GHACTIONS. The `v2/v3/v4` naming reads like versions but the content is domains. Do not vote; merge.
2. **`folderframework`'s plan explicitly defers GHACTIONS** ("stay investigative until a run log is attached"). My `site_impact_audit.md` + `revert_runbook.md` are exactly the missing inputs to its Phase B.
3. **The big cross-cutting find: there are two audit dashboards.** Live `/audit` (FTP) is `audit-dashboard.yml → audit_trail/dashboard_generator.py`; the repo-committed `dashboard/index.html` is `live_tracker.yml → dashboard/generate_dashboard.py`; `audit_systems.py`/`enhanced_audit_dashboard.py` run in **no** workflow. This *reconciles* `folderframework`'s "money_ready is []" with `v2`'s "index.html shows No data" — they describe different dashboards.
4. **v2's bugs are mostly real but mostly not in the live path.** L15/L30 and audit_systems L35 confirmed; `enhanced_audit_dashboard.py` L103 is partly stale (already coalesces None) and misses the hardcoded `win_rate: 55.0`.
5. **My push-safety findings are a shared prerequisite.** Any peer remediation pushed from a stale clone hits the stale-fork trap I documented (88367 ahead / 15 behind).

6. **Structural consistency is the meta-fix (from the external review).** The four folders use three different layouts (v2 = charter-as-folder, v3 = dated SWARM, v4 = flat). Adopt v3's dated SWARM + `swarm_librarian.py` as canonical, add a `validate` subcommand + `AGENT_PROMPT.md` contract, and migrate v4 (mapping in `05_*`). My v4 is the layout deviant; see D8.

7. **Round 2 is complete for all 4 agents (see `06_*`).** `folderframework`, `-v2`, `-v3`, `-v4` all landed; v3 shipped `swarm_librarian.py` v2.1 (`validate`/`--domains`). v3 also found 2 of my GH steps already landed on main and 16 errata in my v4 drop.

8. **Final verdict (see `08_*`).** IMPLEMENT the framework canon + display-only domain wins; PAUSE data/rows/cron/prediction mutations; REJECT fabricated success, real-money sizing, and disproven claims; RETIRE my obsolete steps (O1–O2). **Top blocker = B2 (which dashboard is live).**

9. **Communication layer (see `09_*`).** Antigravity `/swarm` = isolation + artifacts + **real-time blackboard + verifier/monitor roles**. The folderframework has isolation + artifacts but no live channel. Recommendation: pilot **`iac`** (zero-token `recv`, `@`-addressing, `?` work-queue) under the existing SWARM folders, and add a **verifier** (1 per 2–4 workers) + **monitor**. Verified: all 6 candidate repos exist; `iac` is the closest match.