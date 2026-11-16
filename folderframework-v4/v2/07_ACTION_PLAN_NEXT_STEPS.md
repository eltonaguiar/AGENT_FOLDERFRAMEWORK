# 07 — Suggested action plan (next steps)

**Author:** `folderframework-v4` · **Date:** 2026-11-16 ~06:33Z · **Artifact base:** `AGENT_FOLDERFRAMEWORK` @ `a9deb2c`
**Trigger:** all four worktrees have now landed round-2 (v3 landed at `a9deb2c`, 06:31Z). This is the "what next" plan.

> Read with `06_FINAL_FINDINGS_ROUND2.md` (state) and `05_FRAMEWORK_STRUCTURE_REVIEW.md` (structural gaps). This file is the sequenced plan.

---

## 1. State at handoff (what changed since `06`)

- **v3 landed (`a9deb2c`).** It shipped `swarm_librarian.py` **v2.1** with `validate`, `--domains`, multi-src `collect`, `--auto-index`, and top-level `evidence/<DOMAIN>/` — i.e. it **implemented** the structural track (S1/R-8). Plus `AGENT_PROMPT.md` + `DELIVERABLE_FRONTMATTER.md`.
- **Two of my GHACTIONS steps are already done on main** (v3 verified): Step 9 (deploy-race concurrency) landed as `20f6e1cdad1`; Step 7-A1 (`db-freshness-check.yml` archive) — the file no longer exists. → retire both, keep as regression watches.
- **v3 found a ghost-row display mechanism:** a stale 2026-05-31 remediation note at `dashboard_enhancements.js:829-833` prints beside the live count → explains "0 vs 22,947" at the UI layer.
- **Snapshot dedup is a real decision, not dead code:** both copies are live — `universal_pick_resolver.py:1423` (resolver's) and `dashboard_generator.py:1764` (generator's).
- **My own errata owed:** v3 catalogued **16 internal inconsistencies** in my v4 drop (counts 356/358/373, minute-0 189/190, `deploy-fte-index.yml` described both ways, guardian "never commits" vs "writes same path", unpurge `4645d08eee4`, TODOS self-contradictions, branch pop 213/215) and evidence parked in volatile `/tmp/qa3/…`.

## 2. Corrections to MY work (do first — it is cited by peers)

| ID | Correction | Why |
|---|---|---|
| E1 | Recount every GH number at a **fresh SHA** and restate as "as of <sha>" | main moves ~1 commit/min; 356/358/373 drift |
| E2 | Purge `4645d08eee4` everywhere (keep `origin/main` + `2a8421d197e`) | local-only, unrunnable elsewhere |
| E3 | Fix `deploy-fte-index.yml` verdict (no-write vs FTP `/audit/`) to one consistent line | internal contradiction |
| E4 | Reconcile guardian "never commits" (`orphan_items.md`) vs "writes same path" (`site_impact_audit.md`) | v3 sides with "never commits" |
| E5 | Move `/tmp/qa3/*` + `scratch/classify_triggers.py` evidence into `evidence/GHACTIONS/` and commit it | reproducibility |
| E6 | Mark Step 9 + Step 7-A1 **obsolete (landed externally)** in FILES_TO_TOUCH/IMPLEMENTATION_STEPS | keep the record truthful |

## 3. Action plan (sequenced; owner · risk · done-when)

### Phase 0 — Ratify + errata (hours; low risk; unblocks everything)
| ID | Action | Owner | Risk | Done when |
|---|---|---|---|---|
| P0-1 | Ratify: v3 dated-SWARM = canonical; v3 librarian = the one tool (D1/D8/S1/S4) | human/coordinator | none | one-line decision recorded |
| P0-2 | Errata E1–E6 on the v4 GHACTIONS drop | **v4 (me)** | none | peer citations resolve; counts re-pinned |
| P0-3 | Decide **B2**: which dashboard is live (see §4) | human | none | B2 answered → unblocks Phase 2 |

### Phase 1 — Run the validator, fix the baseline (low risk)
| ID | Action | Owner | Risk | Done when |
|---|---|---|---|---|
| P1-1 | `python3 tools/swarm/swarm_librarian.py validate <each swarm>` → publish violations | **v3** | none | violation list committed |
| P1-2 | Fix violations: v2 charter-folder→file; v4 copy into dated root (copy, not move) | v2, v4 | low | validate passes (warn-level) |
| P1-3 | Add `AGENT_PROMPT.md` to every future task; front-matter on new files | all | none | new drops carry it |

### Phase 2 — Domain quick wins (display-only; **gated on B2 + human "display-only OK"**)
| ID | Action | Owner | Risk | Done when |
|---|---|---|---|---|
| P2-1 | Neutral class for exact-zero PnL in `dashboard/generate_dashboard.py:15,30` (display only, **not** WR math) | v2 | low | break-even not red |
| P2-2 | `normalize_side()` so `BUY`/`SELL` don't render short (RC4) | v2 | low | badges correct |
| P2-3 | Money-Ready empty state = "0 classes ready" + per-class verdict/wr/pf (no "No data") | v1 | low | empty list shown truthfully |
| P2-4 | Label/remove hardcoded `sharpe` (0.3/1.35) & `win_rate: 55.0` in `enhanced_audit_dashboard.py` | v2 | low | no hardcoded metrics |
| P2-5 | Remove/annotate stale ghost note `dashboard_enhancements.js:829-833` | v2 | low | live count no longer contradicted |
| P2-6 | Push-safety guardrail: never `git add .github/workflows/`; build patches vs `origin/main` | **v4 (me)** | none | rule in AGENTS.md |

### Phase 3 — Verification (close the open questions; parallelizable)
| ID | Action | Owner | Done when |
|---|---|---|---|
| P3-1 | B2: is `dashboard/index.html` served, or overwritten by `live_tracker.yml` (`alpha_engine/live_dashboard.html` on runner)? | v4 | B2 evidenced |
| P3-2 | Snapshot dedup direction + contract-price unit test at both call sites | v1+v4 | one copy retired, test green |
| P3-3 | Fresh `audit-dashboard.yml` run log → 404/Infinity still live? | **v4** | dated verdict |
| P3-4 | Producer of `hub/data/*.json`; deprecate March file or mark `dna_run_pending` | v2 | hub truth settled |
| P3-5 | GitHub API pass for sports `disabled_manually` flags | v3 | flags confirmed |

### Phase 4 — Deferred / decision-gated (this week+; do NOT start without its decision)
| ID | Action | Gate |
|---|---|---|
| P4-1 | Delete `db_freshness.json` (B2) + doc sweep | consumer re-check |
| P4-2 | Cron stagger pilot — **only** `0 */2` tier, recount at fresh SHA, measure 24 h | explicit go |
| P4-3 | Concurrency backfill in ~20-file batches (dual-mode first) | explicit go |
| P4-4 | Prediction snapshot dedup (markets stay shadow) | unit test first |
| — | **Never:** row deletes, combo fabrication, emitter persistence, real-money sizing, `audit-dashboard.yml` push trigger | charter |

## 4. Decisions needed from the human (blocking)

| ID | Decision | My recommendation |
|---|---|---|
| **B2** | Which dashboard is authoritative: live `/audit` (`audit_trail`) vs `dashboard/` (`live_tracker`) vs legacy scripts? | `audit_trail` for the public site; treat `dashboard/` as secondary until P3-1 proves it served. **Gates all of Phase 2.** |
| B1 | Exact-zero PnL class | neutral (display), not a win; don't touch WR math in the same PR |
| B3 | Money-Ready "has data" | render empty verdict (A), never require ≥1 ready class |
| B4 | Move v4 into dated root? | copy (keep SHA), after P0-2 errata; hold on your OK |
| B5 | Accept display-only scope for Phase 2? | yes — it is low-risk and reversible |

## 5. What I (v4) will do next
1. **P0-2 errata** on my GHACTIONS drop (E1–E6) — it is my work peers cite.
2. **P2-6** push-safety guardrail into `AGENTS.md`.
3. **P3-1** (B2 evidence) + **P3-3** (fresh Actions log).
4. Then, if approved, the **P4-2** cron pilot (worst tier only).

## 6. Non-goals for this next round
No row deletion, no combo/winner generation, no prediction-feed persistence, no real-money sizing, no `audit-dashboard.yml` push trigger, no moving another agent's files, no third librarian.