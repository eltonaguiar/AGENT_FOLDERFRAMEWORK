# Final Review v2 — folderframework-v2 (Audit + Framework Integrity)

**Date:** 2026-11-16  
**Reviewer:** folderframework-v2  
**Peers reviewed:** folderframework, folderframework-v3, folderframework-v4  
**External feedback:** 2026-11-16 framework review (7 structural gaps)

---

## 1. What I agree with (across peers)

- **v4 GHACTIONS deliverable is the highest-quality artifact** — PLAN.md, EVIDENCE_INDEX, IMPLEMENTATION_STEPS, TESTING_PLAN, FILES_TO_TOUCH are all production-grade. The 9 retractions, the two-axis push-hazard test, the stale-fork trap quantification (88367 ahead / 15 behind), and the deterministic `crc32 % 60` stagger are reusable patterns.
- **v3 scaffold is the cleanest structural template** — dated `2026-11-16-SWARM/`, full phase folders, `swarm_librarian.py` with `collect`/`index`, and the pre-final-review checklist are the right baseline.
- **folderframework (v1) correctly rejected the boolean-gate trap** on `db_health.json` (`checks.ghost_rows.ok == true` while `total_ghost_rows == 22947`). This is the same class of error as the GHA “4 whole-fleet hazards” false positive that v4 retracted.
- **Shadow-only prediction markets + contract-price snapshot** is the correct default (PBO 0.603). No real-money sizing without the 6-gate greenlight.

---

## 2. What I disagree with (and why)

| Claim | Peer | Disagreement | Evidence |
|-------|------|--------------|----------|
| "Money-Ready panel shows 'No data'" | v1 / v3 charter | The panel is empty (`summary.money_ready == []`), not broken. The "No data" tile is a fallback for missing JSON, not for an empty verdict array. | `money_ready_verdict.json` generated 2026-11-16T01:44:34Z; `pick_funnel.html` already states nothing is sized. |
| "GHA push hazard exists on main" | early reports | Retracted by v4. Zero hazards when `paths:` filter is considered. | `branch_trigger_audit.md` §2; two-axis test on `eb23252`. |
| "235 stale workflows" | early GHA reports | Sampling artifact (180-run window ≈ 1 h of a ~4 k runs/day fleet). Real stale count ≈ 20 + 12. | `corrections.md` entry. |
| "DB-freshness seam is low-risk" | v4 | The seam is real (manual committer vs artifact-only guardian), but the blast radius is zero only because no PHP/JS/HTML consumer exists. A future dashboard page could re-introduce the dependency. | `orphan_items.md` Finding 1 + `git grep`. |

---

## 3. Decisions required (human or merge-agent)

1. **Canonical structure** — Adopt `folderframework-v3`’s dated `2026-11-16-SWARM/` layout (with configurable `--domains`) as the single source of truth. v4’s flat layout is excellent content but violates the isolation contract.
2. **Agent prompt contract** — Every future agent must receive a one-page `AGENT_PROMPT.md` that hard-codes the exact write path, required filename pattern, required front-matter, and the rule “do not create new top-level folders.”
3. **Validation gate** — Add `swarm_librarian.py validate` (checks required phase folders, evidence links, five canonical files in `07_final_review4/`). Run as pre-commit or before librarian `collect`.
4. **Front-matter requirement** — Every deliverable must start with a small YAML block:
   ```yaml
   ---
   agent: folderframework-v2
   domain: AUDIT
   phase: 2
   status: done
   evidence:
     - path: audit_dashboard/data/db_health.json
       sha: db4cc06ed82
   ---
   ```
5. **Worktree naming rule** — `wt-<domain>-<short-id>` (e.g. `wt-gha-v4`). Librarian `collect` accepts a glob or explicit list.
6. **Phase-gate checklist** — The existing 6-item checklist in v3’s charter is sufficient. The synthesizer rejects any file that does not tick all items.
7. **New-domain escape hatch** — Use `CROSSCUTTING/` + a note requesting a librarian re-scaffold with `--domains` rather than forking the folder layout.

---

## 4. Remaining ambiguities / open questions

- Which `_snapshot_prediction_market_entry` (resolver:934 or dashboard_generator:5493) is actually called by the live `/audit` page? (Needs a live trace or `git grep` on the deployed PHP.)
- Is the 404-JS deploy gap on the audit dashboard still live, or was it already fixed by the NaN/Infinity sanitizer in `production_scanner.py`? (Needs a fresh Actions run log.)
- Should the sports workflows be retired with a banner even if the paper auto-place path is already denied? (Decision: low-risk cosmetic change vs. explicit intent recording.)

---

## 5. Further considerations for research / discussion

- **Evidence attachment standard** — Raw JSON snippets, command output, or small screenshots should live in an `evidence/` subfolder (git LFS or base64-encoded) rather than inline in markdown. This keeps prose clean while preserving reproducibility.
- **Cross-domain synthesis trigger** — When ≥2 domains produce contradictory claims (e.g. DB says “ghost rows are cosmetic”, AUDIT says “they break the Money-Ready gate”), the librarian should auto-create a `06_final_review3/CROSSCUTTING.md` stub and assign a synthesizer.
- **Stale-worktree timeout** — 6 h is reasonable for a single swarm; for a multi-day campaign the timeout should be configurable per charter (e.g. 48 h for GHACTIONS because `origin/main` moves every 60 s).
- **Reproducibility contract** — The final `EVIDENCE_INDEX.md` must contain a one-liner “reproduce with” block for every numeric claim. v4 already does this well; earlier versions do not.

---

## 6. Prioritized “what still needs work” (updated)

### (i) Quick display / correctness fixes (≤ 1 PR, low risk)
- Change `db_health.json` claim language from `checks.*.ok` to `data.total_ghost_rows` and `trading_picks.active_count`.
- Ensure `money_ready_verdict.json` empty array renders as an explicit empty verdict tile with per-class `n`, not a generic “No data” fallback.
- Add the 6-item pre-final-review checklist to every agent prompt.

### (ii) Plumbing fixes (medium effort, reversible)
- Promote v3 `swarm_librarian.py` + scaffold as canonical; add `--domains` and `validate` subcommands.
- Move v4’s excellent GHACTIONS content into a proper dated `2026-11-16-SWARM/` structure so it matches the isolation contract.
- Add front-matter validation to the librarian (fail on missing `agent`, `domain`, `phase`, `evidence`).
- Enforce worktree naming `wt-<domain>-<short-id>` in the prompt contract.

### (iii) Research / strategy work (higher effort, decision-gated)
- Trace the exact call path for `_snapshot_prediction_market_entry` on the live site.
- Re-run `audit-dashboard.yml` with a fresh log to confirm whether the 404-JS / Infinity emission is still present.
- Decide on sports retirement banner (cosmetic vs. explicit intent) and whether the 5 `sports-*.yml` should be renamed `.yml.disabled`.
- Extend the framework to support arbitrary new domains without forking the scaffold (config file or `--domains` flag).

---

## 7. Final recommendation

Adopt the 7 structural fixes above, declare `folderframework-v3` + its librarian the canonical template, and require the agent prompt contract + front-matter for every future swarm. The content quality (especially v4 GHACTIONS) is already high; the remaining work is almost entirely about making the *structure* enforceable and generic. Once those two pieces are in place, later agents will stop inventing their own layouts and the swarm will scale cleanly from 4 agents to 20.