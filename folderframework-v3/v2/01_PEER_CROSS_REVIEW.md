# 01 — Peer cross-review (folderframework-v3 reviewing v1, v2, v4, and itself)

Evidence keys: `AFF` = `eltonaguiar/AGENT_FOLDERFRAMEWORK`; source repo `origin/main` observed advancing `eb23252` → `c284ba25fe4` during this pass (peer warning about ~1 commit/min validated).

---

## Peer: `folderframework` (v1) — claims-hygiene pilot

**What landed:** full phase chain `00_CHARTER` → `04` → `05` → `06` → `07_final_review4` (5 canonical files) + `templates/FINAL_REVIEW.md` + its own `swarm_librarian.py` (`AFF/folderframework/2026-11-16-SWARM/`).

**What I verified independently (all at source-repo `db4cc06ed82`, exact file reads):**

| v1 claim | My result | Verdict |
|---|---|---|
| ghost rows 22,947 while `ok=true`, tier yellow, `threshold_pass=true` | `audit_dashboard/data/db_health.json` byte-exact match | confirmed |
| open 91,705 vs active 21 (`trading_picks`), total 144,407 | byte-exact | confirmed |
| `bt_backtest_trades.open_count` = 29,247,197 is a third population | byte-exact | confirmed |
| `overall.banner_should_show=false` despite the counts | confirmed | confirmed |
| money_ready `[]`, watch `[COMMODITY]`, n_classes=10 | byte-exact, AND live endpoint at 05:53Z still shows `[]` / `[COMMODITY]` | confirmed + extended to live |
| duplicate `_snapshot_prediction_market_entry` at `universal_pick_resolver.py:934` and `dashboard_generator.py:5493` | both line numbers exact | confirmed |

**Upgrade to v1's open question** ("which snapshot copy the live dashboard calls — not traced"): **both copies are live in their own module.** `universal_pick_resolver.py:1423` calls the resolver's copy; `dashboard_generator.py:1764` calls the generator's copy. Dedup direction is a real decision, not a dead-code cleanup (see `05_OPEN_QUESTIONS.md` Q1).

**Defects / gaps in v1's drop:**
1. Its librarian variant is a strict subset (init + index only) of mine — two competing tools violate the framework's own "single source of truth" goal. Resolve per R2 (mine becomes canonical; v1's README already calls its tool "folder init + markdown index only").
2. Phases 2–4 are v1 talking to itself ("No peer reviews existed at clone time") — honest and correct at the time, but the resulting plan carries single-author risk that this v2 pass is designed to close.
3. Zero live HTTP fetches (self-declared). I closed this: all three key endpoints curl'd 06:19Z (see README).
4. `03_DONE/` is empty — v1's findings live only inside its review files. Canon now requires deliverables in `03_DONE/<DOMAIN>/` with front-matter; reviews point at them.

**Verdict:** content authority for the DB/AUDIT claims pilot; its EVIDENCE_INDEX style (one table row per claim) is adopted into canon.

---

## Peer: `folderframework-v2` (v2) — legacy dashboard bug hunt

**What landed:** `00_CHARTER/00_CHARTER.md` (as a folder, off-layout) + `03_DONE/AUDIT/audit_bugs_report.md` ("Audit Bug Findings and Next Steps").

**What I verified independently:**

| v2 claim | My result | Verdict |
|---|---|---|
| Bug 1: `dashboard/generate_dashboard.py:15` zero P/L misclassified negative | line 15 is `pnl_class = "positive" if pick["unrealized_pnl_pct"] > 0 else "negative"` — break-even → negative; same pattern at line 30 | confirmed, fix `>=` correct |
| Bug 2: `audit_systems.py:35` zero-PnL → wrong bucket | wins use `> 0`, losses `<= 0` at lines 35–36 → break-even counts as a loss | confirmed |
| Bug 3: `enhanced_audit_dashboard.py:103` aggregates missing fields incorrectly | line 103 already coalesces (`or 0`) with comment `# 2026-06-04: coalesce explicit None` | **stale — fixed 2026-06-04** |
| `hub/data/integrated_dashboard.json` — no active systems | `active_systems: 0`, 19 unknown / 1 degraded, `last_update: 2026-03-02T19:37` (**8.5 months stale**) | confirmed, worse than reported |
| `hub/data/winning_combos.json` — no winning combos | `total_found: 0` | confirmed |

**Material defect — blast radius unassessed:** only `.github/workflows/live_tracker.yml` invokes any of these scripts (`python <x>.py` grep across workflows). The canonical `/audit` pipeline is `audit_trail/dashboard_generator.py` per AGENTS.md's dependency registry — v2's scripts are a legacy/adjacent surface. Its fixes are therefore *correct but low-impact* for the charter's S1–S6 criteria, and low-risk precisely because the scripts are semi-dormant. Its charter also targets battleground/incubator surfaces the swarm charter never scoped.

**Verdict:** real quick wins (bugs 1–2) to fold into the unified Phase-A list *with the blast-radius caveat written down*; bug 3 dropped as stale; success criteria in its charter need rescoping before any more cycles are spent there (see `05_OPEN_QUESTIONS.md` Q2).

---

## Peer: `folderframework-v4` (v4) — GHACTIONS deep audit

**What landed:** flat (non-dated) layout: charter + 10 heavy `03_DONE/GHACTIONS` files (two run-stamps) + full `07_final_review4/` set. Largest and deepest drop (~110 KB research).

**What I verified independently (source repo + live git state):**

| v4 claim / proposal | My result | Verdict |
|---|---|---|
| Two-axis push-hazard count = 0 ("no whole-fleet push hazard") | consistent with my own reading of the workflow estate; v4 cites reproducible commands | accepted |
| `dynamic-alpha-engine.yml` `timeout-minutes: 90` on main | true — now at **line 118** (v4 cited 115); v4's own drift warning predicted exactly this | confirmed + drift demonstrated |
| Step 9: add concurrency group to `deploy-competition-to-site.yml` | **already landed on main** by `20f6e1cdad1` ("serialize FTP deploy races … per GHACTIONS push-race audit"), incl. `deploy-fte-index.yml`; group string identical to v4's proposal | **obsolete — mark landed**, keep as regression watch |
| Step 7-A1: archive `db-freshness-check.yml` | file **no longer exists** on `origin/main` at all | **obsolete — resolved externally** |
| Step 7-B2: committed `audit_dashboard/data/db_freshness.json` is a stale decoy; guardian is artifact-only | guardian has `upload-artifact@v6`, no commit/push step (current main); committed JSON still exists in tree | confirmed; **B2 still open** |
| Workflow count 373 at audit time | 375 now | drift, as v4 explicitly warns |

**Defects / gaps in v4's drop (from full-file research summary + my checks):**
1. **16 internal inconsistencies** across its own files: workflow counts 356 vs 358 vs 373; minute-0 189 vs 190; push-trigger arithmetic impossible as printed (40 superset vs 47+37 subsets); `deploy-fte-index.yml` described as both "Writes /audit? no" (`push_chain_impact.md`) and FTP target "/audit/" (`site_impact_audit.md`); guardian "never commits" (`orphan_items.md`) vs "writes the same file to the same path" (`site_impact_audit.md`) — my check sides with `orphan_items.md`; incomplete SHA purge (`4645d08eee4` purged in runbook but still present in `push_chain_impact.md`); TODOS self-contradictions (pending items already delivered); branch population 213 vs 215.
2. **Evidence stored in volatile paths** (`/tmp/qa3/...`, `scratch/classify_triggers.py` uncommitted) — violates the reproducibility principle; canon now bans this (AGENT_PROMPT §3).
3. All GitHub-runtime claims self-declared UNVERIFIED (`disabled_manually` flags, run states) — fine as a scope choice, but its sports and db-freshness decisions genuinely need one API pass to close (see `06_FURTHER_RESEARCH.md` F1).
4. Flat layout + no librarian usage, no front-matter, no dated root — works as a one-off, fails as a template.

**Verdict:** adoption with conditions — content is strong enough to act on *after* an errata pass reconciling its 16 inconsistencies and re-pinning numbers at a current SHA; two of its nine steps need retirement first. Its run-stamped `03_DONE` subfolders and sub-agent roster table are adopted into canon.

---

## Self-review: `folderframework-v3` (me)

**What I shipped (drop 1 + this drop 2):** canonical dated scaffold with seeded domain TODOs + charter with S1–S6; librarian v2 (`scaffold`/`--domains`/`collect` multi-src/`--auto-index`/`index`/`validate`); `AGENT_PROMPT.md`; front-matter spec; templates; this review set.

**Known weaknesses (honest):**
1. Drop 1 contained **zero domain research** — framework-only. My charter's S1–S6 were authored from project memory + v-unverified claims; they are now backed by live fetch (06:19Z) only for S3/S4-adjacent items.
2. Same structural drift risk I flag in peers: my `2026-11-16-SWARM/` hardcodes this mission's domains; the generic mechanism (`--domains`) ships in this drop, after the fact.
3. My librarian v1 had no validation — the exact gap the external review named. Fixed here, but only after external prompting: the framework's own "progressive narrowing" did not surface it internally.
4. I did not attempt DB or GHACTIONS domain investigation; S1/S2 numbers ride on v1's work (which I verified) rather than my own queries.

**Verdict on self:** structure/tooling contribution is complete and tested; domain-content contribution is thin and should not be overweighted in any final synthesis.
