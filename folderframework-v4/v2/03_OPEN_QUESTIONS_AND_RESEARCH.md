# 03 — Open questions, ambiguities & further research

## Part 1 — Where the task itself is ambiguous

**Q-A. Are the four folders independent drafts (vote) or domain slices (merge)?**
The naming `folderframework`, `-v2`, `-v3`, `-v4` reads like *versions* of one attempt, but the
content is *domains* (AUDIT, AUDIT-bugs, tooling, GHACTIONS). The framework says disagreements are
settled by "evidence weight + risk," not voting — which implies **merge**, not compete.
→ **Needs coordinator ruling.** My assumption in `02_*` is merge.

**Q-B. What is "the audit system" the human means?**
Three candidate surfaces exist (see D1). Until named, "fix the audit dashboard" is under-specified.

**Q-C. Base SHA authority.**
`origin/main` advances ~every 60 s; every peer pins a different SHA. Which SHA is the reference for
"the final plan"? → Recommend: always re-fetch and cite `git rev-parse origin/main` at write time;
treat older SHAs as historical.

## Part 2 — Open questions carried across peers

| # | Question | Raised by | Status | What would close it |
|---|---|---|---|---|
| Q1 | Which dashboard does the live site actually serve — `audit_dashboard/` (FTP) or committed `dashboard/`? | me (cross-review) | **open** | Check what `findtorontoevents.ca/audit/` serves vs what `live_tracker.yml` commits; is `dashboard/index.html` deployed anywhere? |
| Q2 | Which `_snapshot_prediction_market_entry` copy does the live dashboard import? | `folderframework` (04/05) | **open** | Python caller trace: `grep -rn "_snapshot_prediction_market_entry"` in `audit_trail/` + import graph |
| Q3 | Is the historical 404-JS / Infinity-JSON bug still live on the current runner? | `folderframework` (04) | **open** | Pull a fresh `audit-dashboard.yml` run log (Actions) and grep for `NaN`/`Infinity`/404 |
| Q4 | Did v2 actually run the code, or read it statically? | me (cross-review) | **open** | v2 provides no run output; ask or re-run `audit_systems.py` |
| Q5 | Are `audit_systems.py` / `enhanced_audit_dashboard.py` invoked by anything (cron/manual)? | me (cross-review) | **partly answered** — no workflow runs them; confirm no local cron/README instruction |
| Q6 | Are the 5 sports workflows actually `disabled_manually`? | `folderframework-v2` charter / my `orphan_items.md` | **open (unverifiable in git)** | Requires GitHub API (out of my no-API scope) |
| Q7 | Is `hub/data/*.json` produced by any workflow? | me (cross-review) | **open** | `grep -rl 'hub/data' .github/workflows/` |

## Part 3 — Further research / discussion

**R-1. Dashboard consumption trace (highest value, blocks D1).**
Determine whether `dashboard/index.html` (from `live_tracker.yml`) is ever served publicly or is a
dead repo artifact. If dead, v2's #1 is cosmetic; if live, it outranks some `/audit` work.

**R-2. Fresh Actions run-log pull (closes Q3).**
`gh run list --workflow=audit-dashboard.yml`, then grep the latest green run's log for non-finite JSON
emission and 404s. This converts `folderframework`'s "do not claim it's still open" into a dated verdict.

**R-3. Import/caller graph for the duplicate snapshot function (closes Q2).**
Cheap, decisive; prevents "fixing the unused copy."

**R-4. Quantify current cron drift.**
My stagger was pinned to `ae3f4dc`/`eb23252`; re-run the `crc32 % 60` classifier against today's
`origin/main` to see how many minute-0 collisions remain (main has moved a lot since).

**R-5. `hub/data` producer hunt (closes Q7).**
Map which workflow (if any) writes `integrated_dashboard.json` / `winning_combos.json`; if none,
they are stale artifacts and v2's #4/#5 are data-refresh gaps, not bugs.

**R-6. Adopt `folderframework-v3/tools/swarm/swarm_librarian.py`.**
Re-index all four folders with one tool so `INDEX.md` files agree; my folder used a manual layout.

**R-7. Prediction-market silent-failure audit (new, cross-domain).**
`audit-dashboard.yml` runs the PM steps with `|| echo "... (non-fatal)"` (lines 117–121), so PM failures
are swallowed. Worth a dedicated check: are the Kalshi/Polymarket/consensus steps actually succeeding,
or silently no-op'ing? This is a GH Actions × PREDICTION intersection none of the peers covered.

## Part 4 — Discussion prompts for the human

1. Do you want **one merged final_review4** across all domains, or keep per-worktree plans and treat this `v2/` as the merge proposal?
2. Which dashboard do you actually open — `findtorontoevents.ca/audit/` or a repo-rendered `dashboard/index.html`?
3. Should I (v4) pull the fresh Actions run log to close Q3, or is that another worktree's job?
4. Are the sports workflows intentionally off? (Determines whether the "frozen-but-plausible" banner is wanted.)

---

## Part 5 — Addendum: structural/generic-framework questions (from the external meta-review)

**New open questions**
| # | Question | Why it matters |
|---|---|---|
| Q8 | Which worktree owns the librarian going forward (v3's is canonical per D9)? | Two librarian copies already exist (`folderframework/…/tools/` and `folderframework-v3/tools/swarm/`); a third would be drift. |
| Q9 | Is a restructure allowed to break a peer's *snapshot* path references (e.g. `folderframework/v2/PEER_REVIEW.md` → `folderframework-v4/07_final_review4/`)? | Determines whether D8 can execute cleanly or needs redirect stubs. |
| Q10 | Under the canonical layout, does per-agent peer review live at `05_final_reviewv2/` or stay a top-level `v2/`? | The user asked for a "v2" folder; the framework's phase name is `05_final_reviewv2`. Pick one. |
| Q11 | What is the new-SWARM-vs-append rule? (new dated root vs reuse an existing one) | Review flags this as undefined; without it, agents will either proliferate dated folders or stomp an old one. |

**New research / build items**
- **R-8. Implement and run `validate`** against all four folders; publish the violation list (this turns the review's critique into a measured baseline). Likely hits: v2 charter-as-folder, v4 no dated root, v2 missing evidence front-matter.
- **R-9. Draft `AGENT_PROMPT.md`** and dry-run it on a throwaway domain (e.g. `FRONTEND`) to prove `--domains` truly generalizes (review's issue 1.2).
- **R-10. Specify the phase-gate checklist** (Phase 1 done = all `03_DONE/<domain>` files present + evidence links resolve + INDEX updated) and a stall detector (no commit in N hours → librarian archives).
- **R-11. Evidence sidecar convention.** v4 already uses a `.tsv` for raw tabular evidence (`branch_capability.tsv`); propose this as the standard "raw evidence without polluting markdown" pattern for the front-matter `evidence:` block to point at.