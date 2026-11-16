# 06 — Further research / discussion items

Ranked by leverage. None block D1–D8; each closes a gap that stayed UNVERIFIED across all four agents.

| # | Item | Gap it closes | Suggested executor |
|---|------|---------------|---------------------|
| F1 | **Runtime-state API pass**: `gh api` (or Actions UI) check of the 5 sports workflows' `disabled_manually` flags + last-run dates; db-freshness guardian's recent runs; `audit-dashboard.yml` last conclusion. | Every agent audited git-state only; v4's sports/db-freshness decisions (D4, D3) explicitly await this. | One evidence agent, 30 min, findings to `03_DONE/GHACTIONS/` with front-matter |
| F2 | **Live-surface census of `hub/data/*` and legacy dashboard scripts** (`dashboard/generate_dashboard.py`, `enhanced_audit_dashboard.py`, `audit_systems.py`): who invokes them (cron? systemd? only `live_tracker.yml`?), who reads their JSON. | Q2; determines retire-vs-repair for v2's whole target surface. | Scout agent, grep + server crontab check |
| F3 | **Recompute v4's count bases at one pinned SHA** (workflow files, cron lines, minute-0 share, concurrency coverage) and publish a single reconciled errata; commit the recomputation script into evidence. | v4's 356/358/373 drift and 189/190 minute-0 split; precondition for D6 stagger pilot. | Evidence agent; output replaces v4's `/tmp` references per new canon |
| F4 | **Prediction-market snapshot contract test**: unit test proving contract-price (not spot) semantics at BOTH call sites before any dedup (Q1). | Unblocks R16 without behavior risk; keeps shadow-only guarantee testable. | Domain agent in a future PREDICTION swarm |
| F5 | **Money-Ready live-HTML wording check**: fetch `/audit/` HTML and confirm what text a human actually sees for `money_ready: []` — "No data" string vs empty-table rendering; `cleanup_dashboard.py`'s `nc-nodata` may be a different panel. | R7 currently assumes the empty verdict renders truthfully; v1 never fetched live HTML; my 06:19Z fetch pulled the JSON, not the rendered panel text. | Evidence agent with Playwright/curl + DOM screenshot |
| F6 | **Investigate v4's "88,367 ahead" measurement** with a full (non-shallow) clone. | Q8 — rules out repo-integrity incident vs clone artifact. | Whoever owns v4's machine |
| F7 | **CI gate for this artifact repo**: run `swarm_librarian.py validate --strict` on PRs to `AGENT_FOLDERFRAMEWORK` once one full swarm cycle has run under warn-level front-matter. | D7's graduation path; cheapest durable enforcement. | Librarian (me) after cycle 1 |
| F8 | **Fleet de-duplication map**: `folderframework-*` vs `ghactions-*` vs `auditpage-*` worktree families all touch the same source surfaces; write a one-page ownership matrix per domain per date. | Q7; prevents two fleets writing contradictory plans for the same domain (already nearly happened: deploy-race fix landed from outside the swarm). | Human + librarian jointly |

## Discussion topics (no artifact needed, but worth 10 minutes of human thought)

- **Tension: generic framework vs seeded domains.** My charter's S1–S6 are this-mission-specific and live in a dated folder, while canon is generic. That's the right split — but every new swarm must re-derive success criteria from scratch. A `00_CHARTER.md` *questionnaire* (what does "truthful" mean for THIS mission?) might be a better seed than any domain list.
- **Single-agent phases are the failure mode of the day.** v1's phases 2–4 were self-review; v4 used sub-agents inside one worktree; v2 shipped solo. The framework assumes 6–12 parallel agents — with only 4 worktrees racing on plumbing rather than review depth, `04`/`05`/`06` phases degrade to monologue. Consider: half the fleet scouts, half reviews, nobody does both.
