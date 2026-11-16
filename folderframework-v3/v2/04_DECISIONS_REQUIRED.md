# 04 — Decisions required from the human

Ordered by blocking power. Each: context, options, my recommendation.

---

### D1 — Ratify the canonical framework layout + tooling
Context: three layouts landed (v1/v3 dated nest, v4 flat, v2 minimal). External review names v3's scaffold + librarian as the template. I have since shipped `validate`, `--domains`, `AGENT_PROMPT.md`, front-matter spec.
Options: (a) ratify canon forward-only, grandfather existing folders; (b) ratify + have v4/v2 owners re-deposit in dated form; (c) no canon, keep per-agent freedom.
**My recommendation: (a).** Zero rework cost, stops future divergence, respects the no-edit-others rule. (b) wastes a cycle for cosmetic uniformity.

### D2 — v4's folder: leave flat, or re-deposit dated?
Context: external review wanted v4's work moved into the dated structure; that edit is not mine to make.
Options: (a) leave as-is, canon applies forward; (b) v4 owner re-deposits via `collect`; (c) human performs the move as librarian.
**My recommendation: (a).** The content matters, not the shape; `INDEX.md` + this review make it discoverable.

### D3 — Delete committed `audit_dashboard/data/db_freshness.json` (v4 Step 7-B2)
Context: legacy committer workflow no longer exists on main; guardian is hourly artifact-only; the committed file is a stale RED decoy (`signal_outcomes minutes_stale: 115782` at its last commit). v4 verified zero PHP/JS/HTML consumers via `git grep`. Doc references remain in `AGENTS.md`, `HEARTBEAT.md`, `docs/MYSQL_ENV_SETUP.md`.
Options: (a) delete file + sweep doc refs in one PR; (b) leave it.
**My recommendation: (a).** Blast radius verified zero-consumers; the decoy actively misinforms.

### D4 — Sports workflows: retire-with-banner (C1), leave frozen (C2), or re-enable (C3)?
Context: 5 `sports-*.yml` retain live cron blocks; `disabled_manually` is GitHub-side, invisible to git, UNVERIFIED by all agents. `/live-monitor/sports-betting.html` may be rendering month-old ROI as current.
Options: v4's C1/C2/C3 as above.
**My recommendation: C1 after one GitHub-API check** (F1) — if flags confirm disabled, retire with a date-stamped banner + `.yml.disabled` rename. Do NOT C3: re-enabling re-arms the auto-place path with zero live exercise.

### D5 — Branch pruning tiers (v4)
Context: 215 remote branches; 45% are one family (`claude/fervent-knuth-*`); 102 idle ≥90d.
Options: (a) Tier 0 only (7 ancestor-merged deletes); (b) Tiers 0–1 (bulk 102); (c) defer all.
**My recommendation: (a) now; (b) only via its own dated swarm with API-verified inactivity** — memory correction `gha_stale_workflow_count` stands as the cautionary precedent for artifact-driven mass actions.

### D6 — Cron stagger scope
Context: ~52.5% of cron lines at minute 0 (recomputed count pending; bases drifted between v4's own files).
Options: (a) full per v4 tables; (b) pilot worst tier (`0 */2`, 15 files) + 24 h observation; (c) skip.
**My recommendation: (b).** Deterministic, reversible, semantics-preserving — but counts must be re-pinned at a fresh SHA first (v4's numbers span 356–375 files depending on snapshot).

### D7 — Front-matter enforcement level
Options: (a) warn (shipped); (b) `--strict` CI gate on this repo from day one.
**My recommendation: (a) for the first full swarm cycle, then (b).** A lint nobody has lived under yet should not hard-fail; calibrate on real violations first.

### D8 — v2's AUDIT findings: fold into the unified plan?
Context: bugs 1–2 verified real, bug 3 stale (fixed 2026-06-04); scripts feed `live_tracker.yml`, not the canonical `/audit` pipeline; `integrated_dashboard.json` is 8.5 months stale with `active_systems: 0`.
Options: (a) fold bugs 1–2 as Phase-A quick wins + investigate whether the hub JSONs are live surfaces; (b) pass entirely as off-charter.
**My recommendation: (a) with the blast-radius note attached.** The fixes are trivial and the staleness finding (8.5 months, 0 active systems) is itself actionable intelligence about a possibly-dead pipeline.
