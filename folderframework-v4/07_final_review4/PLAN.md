# PLAN — GH Actions Health & Push-Safety (folderframework-v4)

**Date:** 2026-11-16
**Domain:** GitHub Actions (`.github/workflows/`) for `eltonaguiar/findtorontoevents_antigravity.ca`
**Status:** Report + runbook. No remediation applied. Human-in-the-loop merge required.

---

## 1. Problem statement (one paragraph)

The repository runs a very large GitHub Actions fleet (≈358 workflow files, hundreds of cron lines,
bots committing to `main` roughly every 60 s). A swarm pass was asked to audit the workflow health:
what fires on push, whether the schedule is self-DoS-ing at minute 0, whether the push chain can
re-trigger itself, whether any resurrected workflow would start writing the live `/audit` site, and how
to safely undo anything the swarm lands. The audit found **no whole-fleet push hazard on main**, a
**real stale-fork push-safety trap** in any local clone, a **minute-0 cron pile-up**, and two
**silent-degradation orphans** (DB-freshness seam, frozen sports workflows) — but also retracted an
earlier false P1 so the next auditor does not re-raise it.

---

## 2. Root causes (with evidence)

| # | Root cause | Evidence |
|---|---|---|
| RC1 | **Push-trigger "hazard" was a false positive.** Missing `branches:` alone is not sufficient — `paths:` also bounds blast radius. Two-axis test (no `branches:` **and** no `paths:`) yields **0** hazards on `origin/main` @ `eb23252`. | `03_DONE/GHACTIONS/2026-11-15_21-00-33_EST_ghactions/branch_trigger_audit.md` §0, §2 |
| RC2 | **Stale-fork push trap.** Local clone is 88367 ahead / 15 behind `origin/main`; `.github/workflows/` delta is 12 rows (9 `D` + 1 `M` + 2 `R`). A wholesale `git add .github/workflows/` reverts a live fix and resurrects deletions. | `push_chain_impact.md` lead finding; `revert_runbook.md` §0 |
| RC3 | **`dynamic-alpha-engine.yml` timeout regression.** Main pins `timeout-minutes: 90` (line 115) to escape cancel-churn; local HEAD carries `60` (line 112). Naive push reintroduces the churn. Blob SHAs differ: main `d2ec26fef7…` vs HEAD `c2dce7bb2d…`. | `revert_runbook.md` §0, §2 |
| RC4 | **Minute-0 cron concentration.** 189/360 cron lines (52.5 %) fire at minute 0; worst tiers `0 */2` (15 files), `0 */4` (13), `0 */6` (13) all collide at hours 0/4/8/12/16/20. | `cron_stagger_plan.md`; `cron_verification.md` |
| RC5 | **Push-chain amplification gaps.** 192/356 files have no `concurrency:` guard; 26 dual-mode (`schedule`+`push`) files are the highest feedback risk; group naming is inconsistent. | `push_chain_impact.md` §"Concurrency Coverage Gap"; `cron_stagger_plan.md` |
| RC6 | **DB-freshness committer/runner seam.** `db-freshness-check.yml` is `workflow_dispatch`-only (commits `db_freshness.json`); `db-freshness-guardian.yml` runs hourly but **only uploads an artifact, never commits** → the committed JSON can only age. | `orphan_items.md` Finding 1 |
| RC7 | **Sports workflows frozen-but-plausible.** Claimed `disabled_manually`, but no git-visible `.disabled` rename; `/live-monitor/sports-betting.html` keeps rendering month-old ROI as current with no banner. 176-day vs ~43-day ages measure different things. | `orphan_items.md` Finding 2 |
| RC8 | **`/audit` resurrect risk is outside the 12-file delta.** `deploy-competition-to-site.yml` has `/audit` in its push paths and **no concurrency group**; `deploy-fte-index.yml` likewise writes `/audit/`. | `site_impact_audit.md` §6.4; `push_chain_impact.md` named-hazard section |

---

## 3. Proposed solution architecture

Four independent workstreams, ordered by risk and reversibility. They are deliberately **decoupled** —
no fix depends on another landing.

**A. Lock in the audit truth (docs, zero-risk).** Keep the 10 deliverable docs as the canonical record
(this folder). They are already on `main` (`ac598cefd45`, `db4cc06ed82`).

**B. Push-safety guardrail (process, zero-risk).** Never `git add .github/workflows/` wholesale. Build any
workflow patch against `origin/main`'s blob. Enforce the two-axis `push_unbranched_nopaths` vocabulary so
RC1 is never re-derived as a P1.

**C. Cron stagger + concurrency (behavioral, reversible).** Apply the deterministic `crc32 % 60`
stagger to the minute-0 pile-ups; add `concurrency.group: ${{ github.workflow }}-${{ github.ref }}` +
`cancel-in-progress: false` to uncovered files. Stagger only — never delete crons in the 17
`github.event.schedule` dispatch files.

**D. Orphan remediation (behavioral, decision-gated).** DB-freshness: archive the legacy manual workflow
(A1) **and** make the guardian the single source of truth (B2: delete the committed `db_freshness.json`,
keep the artifact) — A and B are independent. Sports: retire with an explicit date-stamped banner + commit
the `.yml.disabled` rename (C1) so the tree records intent.

---

## 4. Phased rollout

### Phase A — Preserve & guardrail (now, zero-risk)
- Land this folder on `AGENT_FOLDERFRAMEWORK/main` (this commit).
- Adopt the push-safety rule in every agent's workflow: docs only, file-by-file staging.

### Phase B — Cron & concurrency (next, low-risk, reversible)
- Apply stagger tables from `cron_stagger_plan.md` to the 5 worst cron tiers.
- Add concurrency groups to the 192 uncovered files, worst-first (dual-mode first).
- Add a lint check (pre-commit / CI) implementing the stagger spec so drift cannot reappear.

### Phase C — Orphan fixes (decision-gated, separate PRs)
- DB freshness: A1 (archive legacy) + B2 (guardian as source of truth) as one small PR.
- Sports: C1 (retire banner + `.yml.disabled` rename) as a separate, dated PR.
- `/audit` deploy race (RC8): add a concurrency group to `deploy-competition-to-site.yml`.

---

## 5. Risks and mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| Reintroducing 90→60 timeout churn | High | `git checkout origin/main -- .github/workflows/dynamic-alpha-engine.yml`; verify `timeout-minutes: 90` at line 115 |
| Resurrecting 9 deleted workflows | Med | Pre-push: `git diff --name-status HEAD origin/main -- .github/workflows/` must be empty; `ls-tree` counts must match (373) |
| Cron stagger re-triggering a mis-set mode | Med | Stagger only, never delete; preserve all `github.event.schedule` branches (17 files) |
| `/audit` deploy race from a new writer | Med | Only `deploy-competition-to-site.yml` + `deploy-fte-index.yml` matter; add concurrency groups before touching either |
| Acting on a stale SHA | Med | `origin/main` advances ~every 60 s — `git fetch origin main` immediately before any delta claim |
| Sports banner announcing a retirement that gets reversed | Low | Date-stamp the banner so un-retiring is a one-line revert |

---

## 6. Success metrics

- `git diff --name-status HEAD origin/main -- .github/workflows/` returns **0 rows** before/after any push.
- `grep -n "timeout-minutes: 90" dynamic-alpha-engine.yml` hits **line 115**.
- `ls-tree` workflow count on HEAD == `origin/main` (373 at time of audit).
- Minute-0 cron share drops from **52.5 %** toward ~1-file-per-minute per tier.
- Concurrency coverage rises from 46.1 % toward 100 % on dual-mode files first.
- Every remediation lands with a matching entry in `TESTING_PLAN.md` and a revert line in the runbook.