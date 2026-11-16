# Original Prompt
**Swarm / Isolated-Worktree Framework for the Audit System**  
(Designed for the findtorontoevents.ca / `eltonaguiar/findtorontoevents_antigravity.ca` codebase, with explicit handling of DB hygiene, GitHub Actions, audit dashboard, prediction markets, and research worktrees.)

This is a practical multi-agent protocol that combines:
- Isolated worktrees (so agents never clobber each other)
- Structured artifact folders (so nothing is lost)
- Phased collaborative review (so the final plan is stress-tested)
- Explicit hand-off contracts and quality gates
- Git-native preservation (cherry-picks + dated SWARM folders)

### 1. Core Principles

1. **Isolation first** — Every agent works in its own git worktree (or fresh branch). No shared working directory until Phase 4.
2. **Artifacts over chat** — The only durable output is markdown + JSON in a dated folder. Chat is ephemeral.
3. **Progressive narrowing** — Broad exploration → peer review → subset synthesis → final verified plan.
4. **Evidence-linked** — Every claim in a review must point to a file path, commit SHA, live URL, or query result.
5. **Fail-safe preservation** — Even if an agent dies, its worktree + the SWARM folder still contain the `.md` files.
6. **Human-in-the-loop gates** — Final_review4 is a *plan*, not an automatic merge. A human (or a designated “merge agent”) decides what lands.

### 2. Directory Layout (Local + Optional Commit)

```text
2026-11-16-SWARM/
├── 00_CHARTER.md                 # scope, success criteria, non-goals, agent roster
├── 01_TODO/
│   ├── DB/
│   ├── GHACTIONS/
│   ├── AUDIT/
│   ├── PREDICTION/
│   └── CROSSCUTTING/
├── 02_IN_PROGRESS/               # agents drop intermediate notes here
├── 03_DONE/                      # completed individual deliverables
│   ├── DB/
│   ├── GHACTIONS/
│   ├── AUDIT/
│   └── PREDICTION/
├── 04_final_review/              # Phase 2 – each agent’s first peer review
│   ├── agent_A_final_review.md
│   ├── agent_B_final_review.md
│   └── ...
├── 05_final_reviewv2/            # Phase 3 – second pass after reading others
├── 06_final_review3/             # Phase 4 – subset synthesis (3–5 agents)
├── 07_final_review4/             # Phase 5 – final verified plan
│   ├── PLAN.md
│   ├── TESTING_PLAN.md
│   ├── IMPLEMENTATION_STEPS.md
│   ├── FILES_TO_TOUCH.md
│   └── EVIDENCE_INDEX.md
└── 99_archive/                   # old worktrees or abandoned branches
```

**Git practice**  
- Create a dated branch: `swarm/2026-11-16-audit-hygiene`.  
- Agents commit only their `.md` files (and any small JSON evidence) into their worktree.  
- A “librarian” agent (or human) cherry-picks the useful `.md` files into the SWARM folder on main (or on the swarm branch).  
- Never force-push; use `git worktree add` so the main checkout stays clean.

### 3. Agent Roles (Recommended Roster)

| Role | Responsibility | Isolation |
|------|----------------|---------|
| **Scout / Domain Agent** | Deep dive on one area (DB, GHA, Audit page, Prediction) | Own worktree |
| **Reviewer** | Reads others’ work, writes structured critique | Own worktree or same as scout |
| **Synthesizer** | Builds final_review3/4 from the best pieces | Separate worktree |
| **Evidence Agent** | Pulls live DB health, GitHub Actions runs, recent commits, uncommitted diffs | Short-lived |
| **Librarian** | Cherry-picks, organizes SWARM folder, maintains CHARTER | Minimal |

You can run 6–12 agents in parallel. Overlap is intentional — multiple eyes on the same problem surface contradictions.

### 4. Phased Collaborative Protocol

**Phase 0 – Charter (15–30 min, human or lead agent)**  
Write `00_CHARTER.md` containing:
- Exact success criteria (e.g. “ghost-row claim matches db_health.json”, “Money-Ready panel renders”, “prediction-market PnL uses contract prices”)
- Out of scope
- Known live URLs and key files
- Agent assignments

**Phase 1 – Isolated Attempts**  
Each domain agent works in its own worktree:
```bash
git worktree add ../wt-db-agent swarm/2026-11-16-db
cd ../wt-db-agent
# do the investigation
# write findings into 01_TODO/DB/ or 03_DONE/DB/
git add *.md && git commit -m "DB agent: ghost-row and open-bloat analysis"
```
Agents are free to experiment, write scripts, query the live dashboard, etc. They only commit markdown (and small evidence JSON).

**Phase 2 – First Peer Review (`final_review/`)**  
Each agent:
1. Pulls the latest SWARM artifacts (or is given a shared snapshot).
2. Reviews its own work *and* at least two other agents’ work.
3. Writes `04_final_review/agent_X_final_review.md` with this template:

```markdown
# Final Review – Agent X
## What I agree with
## What I disagree with (and why, with evidence)
## Missing evidence / open questions
## Proposed changes to my own work after reading others
## Risk rating (High/Med/Low) for each proposed fix
```

**Phase 3 – Second Pass (`final_reviewv2/`)**  
Agents re-read the Phase-2 reviews, update their thinking, and write a shorter `final_reviewv2` that only contains:
- Revised recommendations
- Explicitly resolved disagreements
- Remaining blockers

**Phase 4 – Subset Synthesis (`final_review3/`)**  
Only 3–5 agents (the strongest domain experts + one synthesizer) participate. They produce a single consolidated document that:
- Merges the best ideas
- Explicitly discards the rest (with reasons)
- Lists residual risks

**Phase 5 – Final Verification (`final_review4/`)**  
A final small group (or the synthesizer + evidence agent) does four things:
1. Re-checks the live site and recent GitHub Actions runs.
2. Inspects any local uncommitted files or recent commits that might contain relevant fixes.
3. Writes the four canonical outputs:
   - `PLAN.md` – high-level what and why
   - `IMPLEMENTATION_STEPS.md` – ordered steps with exact files
   - `TESTING_PLAN.md` – how to verify each change
   - `FILES_TO_TOUCH.md` – every path, why, and risk
4. Adds an `EVIDENCE_INDEX.md` linking every claim to a path, SHA, or live URL.

### 5. Document Templates (Key Sections)

**PLAN.md skeleton**
- Problem statement (one paragraph)
- Root causes (bullet list with evidence)
- Proposed solution architecture
- Phased rollout (Phase A, B, C)
- Risks and mitigations
- Success metrics

**IMPLEMENTATION_STEPS.md**
- Step 1: Exact file + diff description or function name
- Step 2: …
- Rollback plan for each step

**TESTING_PLAN.md**
- Unit / script tests
- Live verification steps (curl the dashboard, check specific JSON fields)
- Regression checks (ghost-row count, Money-Ready panel, prediction-market badge)
- Manual checklist for human

### 6. Best-Practice Safeguards

- **Worktree hygiene**: Always `git worktree prune` after the swarm. Keep the SWARM folder on a dedicated branch that can be merged or discarded cleanly.
- **Evidence over opinion**: A review without a file path or live URL is invalid.
- **No silent overwrites**: Agents never edit each other’s files; they only write new review files.
- **Timeout and kill criteria**: If an agent’s worktree has no commits after N hours, the librarian archives it.
- **Conflict resolution**: In final_review3/4, disagreements are resolved by “evidence weight + risk”, not voting. The synthesizer documents the decision.
- **Security / secrets**: Agents never commit `.env`, keys, or full database dumps. Only redacted evidence.
- **Reproducibility**: Every final plan must be executable by a fresh agent given only the SWARM folder and the repo.

### 7. Example Application to Your Current Issues

| Domain | Phase-1 Agent Focus | Likely Final_review4 Items |
|--------|---------------------|----------------------------|
| **DB** | Ghost rows 22 947 vs “0” claim, open-bloat 91 k vs 21 active, PnL integrity | Data-driven Truth Layer; fix db_health.json duplicate keys; backlog resolver |
| **GHACTIONS** | audit-dashboard.yml, PM signal workflows, deploy gaps (404 JS) | Persist intended prediction-market files; fix Infinity/NaN JSON emission |
| **AUDIT** | Money-Ready “No data”, IC Analysis, stale hardcoded notes, KPI labeling | Sanitize JSON, drive claims from live files, label every tile with n |
| **PREDICTION** | Kalshi/Polymarket emitters gated out, spot-pricing distortion, ephemeral files | Decide which feeds to persist; fix `_snapshot_prediction_market_entry`; shadow-only status |

### 8. Lightweight Tooling Suggestions

- A tiny `swarm_librarian.py` that:
  - Creates the dated folder structure
  - Cherry-picks commits matching `*.md` from worktrees
  - Generates an index of all review files
- Optional: a simple checklist in `00_CHARTER.md` that agents must tick before writing their final_review.

This framework is deliberately heavy on artifacts and light on real-time chat. It scales from 4 agents to 20, survives crashes, produces a single auditable plan, and maps cleanly onto your existing WIRED_IN / GHACTIONS / audit_dashboard layout. You can start with a single domain (e.g. AUDIT page fixes) as a pilot and expand once the process feels smooth.
