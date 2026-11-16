# 02 — Final recommendations & decisions required

## Part 1 — Final recommendations (what I would do, in order)

These merge the best of all four folders. Ordered by risk (lowest first). Each is reversible.

**R1. Adopt a single evidence rule across all folders.** Every claim = path + SHA/command/URL, or it is dropped. (v3's `EVIDENCE_INDEX.md` template already encodes this; apply it to v2's bug list retroactively.)

**R2. Fix the two dashboards question before writing any UI code (blocks v2's #1–#3).** Decide which dashboard is authoritative (see D1). If it is the live `/audit`, then v2's `dashboard/generate_dashboard.py` fixes are lower priority than `audit_trail/dashboard_generator.py`; if it is `dashboard/index.html`, then `live_tracker.yml` is the pipeline to harden.

**R3. Land GH Actions safety first — it gates everyone's remediation.** Any peer code/workflow change pushed from a stale clone will hit the stale-fork trap. Concretely:
- Add the push-safety rule to `AGENTS.md` (never stage `.github/workflows/` wholesale).
- Do **not** commit the untracked `.github/workflows/lint.yml` (unbounded `push:` + untracked deps).
- Keep `dynamic-alpha-engine.yml` at `timeout-minutes: 90`.

**R4. Then, low-risk GH Actions hygiene (my Steps 4–6):** cron minute-0 stagger + `concurrency:` coverage on dual-mode files. Stagger only, never delete crons.

**R5. AUDIT claim hygiene (folderframework's Phase A) — do it, it is display-only and correct.** Drive ghost/open/active counts from `data.*`, render `money_ready: []` explicitly with per-class `n`. Do **not** delete the 22,947 ghost rows or 91,705 open rows in the same pass.

**R6. Add the `/audit` deploy concurrency group (my Step 9)** to `deploy-competition-to-site.yml` — a standing hazard independent of any Phase A outcome.

**R7. Orphans (decision-gated):** DB-freshness archive + guardian-as-source-of-truth (A1+B2); sports retire-with-banner (C1). Keep these as separate, dated PRs.

**R8. Prediction markets stay shadow.** No emitter persistence, no copy trading (PBO 0.603). Re-measure only with a fresh run log.

**Explicitly deferred / rejected (with reason):**
- Reject: deleting ghost/open rows to "make the number zero" (hides duplicates; no rollback tested).
- Reject: persisting Kalshi/Polymarket emitter files (conflicts with shadow decision).
- Defer: `_snapshot_prediction_market_entry` dedup until a caller trace proves which copy the live dashboard imports.

---

## Part 2 — Decisions required (human / coordinator)

| # | Decision | Options | My recommendation | Why it matters |
|---|---|---|---|---|
| **D1** | **Which audit dashboard is authoritative?** | (a) live `/audit` = `audit-dashboard.yml`→`audit_trail/`; (b) repo `dashboard/index.html` = `live_tracker.yml`→`generate_dashboard.py`; (c) legacy `audit_systems.py`/`enhanced_audit_dashboard.py` (manual) | (a) for the public site; treat (b) as a secondary/mirror until proven consumed | Determines where v2's fixes and folderframework's plan actually land. Today effort is split across three codebases. |
| **D2** | **One consolidated final plan, or per-domain plans?** | merge vs per-domain | Merge into one `07_final_review4/` with domain sections (AUDIT, GHACTIONS, DB, PREDICTION) | The framework expects a single final_review4; four folders currently imply four plans. |
| **D3** | **Execute remediation, or plan-only?** | apply vs plan | Plan-only now; apply R3/R4 (safety) first as a small PR | Peers chose plan-only; but the push-safety trap argues for landing the guardrail early. |
| **D4** | **Prediction markets: shadow forever or promote?** | shadow vs promote | Shadow | PBO 0.603; promotion is high-risk. |
| **D5** | **DB ghost rows / open bloat: label or delete?** | label vs delete | Label (display) only | Deletion is irreversible and untested; labeling is truthful. |
| **D6** | **Untracked `.github/workflows/lint.yml`** | own repo / rewrite+filter / leave | Rewrite with `branches:[main]` + drop `Windows/` steps, then its own PR — or leave untracked | Committing as-is = guaranteed-red on every push. |
| **D7** | **Is `folderframework` the canonical pilot, or is `folderframework-v2`'s bug list the deliverable?** | pilot vs bug-list | Both: pilot for DB/claims, v2 for code-level bugs in the dashboard the user actually reads | Clarifies which artifact the human treats as "the answer." |

**Blocking question for the human:** D1 must be answered before any UI code is written. Everything else can proceed in parallel.

---

## Part 3 — Addendum: framework-structure track (from the external meta-review)

These sit **above** the domain work: get the container right first so per-domain content lands
consistently. Full analysis in `05_FRAMEWORK_STRUCTURE_REVIEW.md`.

### Additional recommendations
- **R9. Declare v3 + `swarm_librarian.py` the canonical template.** One allowed layout: the dated `YYYY-MM-DD-SWARM/` root.
- **R10. Add `validate` + `--domains` to the librarian.** `validate` checks: required phase folders exist; every `03_DONE/` file has a resolving evidence link; `07_final_review4/` has the 5 canonical files; flag files outside the allowed tree. `--domains DB,GHACTIONS,…` makes domains data, not code.
- **R11. Write a one-page `AGENT_PROMPT.md` contract.** Every agent gets: exact write path (`…/03_DONE/<DOMAIN>/`), filename pattern (`<agent>_<topic>.md`), required sections, and "do not create new top-level folders; request new domains via CROSSCUTTING."
- **R12. Require a tiny YAML front-matter block** (`agent`, `domain`, `phase`, `status`, `evidence:`) on every deliverable; keep prose free-form. Demonstrated below.

### Additional decisions required
| # | Decision | Options | My recommendation |
|---|---|---|---|
| **D8** | Migrate v4 to the dated-SWARM layout? | migrate now vs keep flat | **Migrate**, but hold on approval — a peer already cites `folderframework-v4/07_final_review4/` by path. Mapping in `05_*` §3. |
| **D9** | One librarian or several? | v3's only vs keep per-folder scripts | **v3's `swarm_librarian.py` only**; add `validate` + `--domains`; do not fork a third copy. |
| **D10** | Make `AGENT_PROMPT.md` + front-matter mandatory? | mandatory vs optional | **Mandatory** — it is the cheapest consistency lever. |
| **D11** | Generic domains source of truth? | hard-coded vs `swarm_config.yaml`/`--domains` | **Config/CLI**; `CROSSCUTTING` as the escape hatch. |

### Front-matter demo (adopt this header on my future files)
```yaml
---
agent: folderframework-v4
domain: GHACTIONS
phase: 2
status: done
evidence:
  - path: 03_DONE/GHACTIONS/2026-11-15_21-00-33_EST_ghactions/site_impact_audit.md
  - sha: origin/main@eb23252219786dc09362a5a500aef2f9bc6f794f
---
```