# SWARM Charter — Audit System Hygiene (2026-11-16)

**Scope:** Fix audit dashboard and system hygiene issues found by `audit_systems.py` and `enhanced_audit_dashboard.py`.

**Non-goals:** Reimplement all trading strategies from scratch. Only fix/hygiene issues that block correct dashboard display and active system reporting.

**Agent Roster:**
- Agent A (Scout/DB): Investigate Battleground system WR=0%, forward test inactivity, dashboard missing active systems
- Agent B (Reviewer): Read Agent A's work, review audit dashboard HTML/JSON structure
- Agent C (Synthesizer): Build Phase 3/4 synthesis
- Librarian: Cherry-pick `.md` artifacts, maintain SWARM folder

**Success Criteria (must be verified before merging):**
1. ✅ `audit_systems.py` no longer reports "ALL Battleground systems showing 0% WR" — Battleground shows reasonable WR (≥40%) or clear explanation in TODO/DONE
2. ✅ Hub integrated dashboard `integrated_dashboard.json` shows `active_systems > 0` (≥1 active system listed), `status` not all "unknown"
3. ✅ `winning_combos.json` shows `total_found > 0` (at least 1 winning combo found) OR clear "need to run DNA backtester" note in TODO/DONE with next steps
4. ✅ `dashboard/index.html` renders without "Money-Ready: No data" — active picks table shows correct Unrealized P/L classes (positive/negative badges work)
5. ✅ `enhanced_audit_dashboard.py` generates a dashboard that shows J Bravo FVG as prop-firm winner (Sharpe ≥1.0, win rate ≥65%) — verified by reading the output or HTML

**Known live URLs / key files:**
- `dashboard/live_picks.json` — current live picks feed
- `hub/data/integrated_dashboard.json` — dashboard status JSON
- `hub/data/winning_combos.json` — winning combos JSON
- `audit_systems.py` — current audit script that finds issues
- `enhanced_audit_dashboard.py` — enhanced dashboard script
- `dashboard/generate_dashboard.py` — HTML dashboard generator

**Immediate next steps (Phase 1 — isolated attempts):**
1. Agent A: Run `audit_systems.py`, examine `battleground/data/closed_picks.json`, check forward test DB `incubator/forward_test.db`, regenerate `integrated_dashboard.json`, check `winning_combos.json` status
2. Agent B: Run `enhanced_audit_dashboard.py`, examine `dashboard/live_picks.json` structure, run `generate_dashboard.py`, inspect `index.html` for correct badge classes
3. Agent C: Examine all audit dashboard JSON schemas, write findings into `02_IN_PROGRESS/` and `03_DONE/` as markdown

**Artifact format:** Only `.md` and small JSON (<1KB) evidence files. No scripts or large data files committed to SWARM.

**Git practice:**
- Create dated branch: `swarm/2026-11-16-audit-hygiene` from `folderframework-v2`
- Agents commit only `.md` files + small evidence JSON to their worktree
- Librarian cherry-picks useful `.md` files into the SWARM folder on main
- Never force-push; use `git worktree add` for isolation
