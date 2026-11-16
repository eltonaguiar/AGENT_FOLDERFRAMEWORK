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



========
**Review of `eltonaguiar/AGENT_FOLDERFRAMEWORK`**

The agents did a solid job materializing the framework you described. The root `README.MD` is essentially the protocol I outlined earlier, and the versioned folders (`folderframework-v2`, `v3`, `v4`) show real attempts to turn it into concrete artifacts. `v3` is the cleanest scaffold (with a working `swarm_librarian.py`), while `v4` is a strong domain-specific execution (GHACTIONS) that already produces high-quality `PLAN.md`, evidence index, and implementation steps.

### Significant Issues / Gaps the Agents Missed

1. **Inconsistent structure across versions (the biggest practical problem)**
   - `v2` uses `00_CHARTER/` (folder) instead of `00_CHARTER.md` (file).
   - `v3` has a full dated `2026-11-16-SWARM/` with proper `01_TODO/`, `03_DONE/`, review phases, and templates.
   - `v4` abandons the dated SWARM root and puts `00_CHARTER.md` + `03_DONE/` + `07_final_review4/` directly under `folderframework-v4/`.
   - Result: no single canonical layout. Agents (and humans) will put files in different places.

2. **Domain folders are hard-coded and not generic**
   - Domains (`DB`, `GHACTIONS`, `AUDIT`, `PREDICTION`, `CROSSCUTTING`) are baked into the scaffold script and READMEs.
   - The framework is supposed to be generic so it can be reused for arbitrary tasks. There is no clean way for an agent to declare a new domain (e.g. `FRONTEND`, `SECURITY`, `ML_CALIBRATION`) without forking the structure.

3. **No enforcement mechanism for placement**
   - The librarian script can `collect` and `index`, but nothing prevents an agent from dropping files in the wrong phase folder, using inconsistent naming, or skipping required templates.
   - No validation step that fails if required files (e.g. `PLAN.md` with specific headings) are missing or if evidence links are broken.

4. **Missing operational pieces**
   - No agent prompt templates that force the structure (the single most effective consistency tool).
   - No “schema” or machine-readable contract (JSON schema / front-matter) for review files and final plans.
   - No clear rule for when to create a new dated SWARM vs. append to an existing one.
   - Limited handling of cross-domain work (CROSSCUTTING exists in v3 but is under-specified).
   - No guidance on how agents should name their worktrees or how the librarian discovers them.

5. **Evidence and reproducibility gaps**
   - `v4` is excellent on evidence linking, but the earlier versions are mostly empty scaffolds.
   - No standard way to attach raw evidence (command output, JSON snippets, screenshots) without polluting the markdown.
   - The librarian’s `collect` is useful but is not automatically invoked; agents must remember to run it.

6. **Phase transition rules are under-specified**
   - When is Phase 1 “done”? Who decides the swarm moves from `03_DONE` to `04_final_review`?
   - No timeout / stall detection beyond the original suggestion.
   - No conflict-resolution protocol when two agents produce contradictory `final_review` files.

### How to Get Consistent Folder Structure Without Killing Creativity

The goal is **strict on placement and required artifacts, loose on content**.

**1. Make the scaffold the single source of truth (do this first)**
- Promote `folderframework-v3`’s `2026-11-16-SWARM/` layout as the only allowed structure.
- Extend `swarm_librarian.py scaffold` so it is the *only* way to create a new swarm folder.
- Add a `--domains` flag so domains are configurable:
  ```bash
  python3 tools/swarm/swarm_librarian.py scaffold --date 2026-11-17 --domains DB,GHACTIONS,AUDIT,PREDICTION,FRONTEND,SECURITY
  ```

**2. Agent prompt contract (highest leverage)**
Give every agent a short, mandatory preamble that includes:
- Exact path where it must write (`YYYY-MM-DD-SWARM/03_DONE/<DOMAIN>/`)
- Required filename pattern (`<agent_or_worktree>_<topic>.md`)
- Required sections (or a link to a template)
- Instruction: “Do not create new top-level folders. If you need a new domain, note it in CROSSCUTTING and request a librarian run.”

**3. Lightweight validation (add to librarian)**
Add a `validate` subcommand that checks:
- Required phase folders exist
- Every file in `03_DONE/` has a corresponding evidence note or link
- `07_final_review4/` contains the five canonical files
- No files outside the allowed structure (or flag them)

Run it as a pre-commit hook or as a librarian step before merging.

**4. Front-matter or simple convention for creativity**
Allow agents full freedom *inside* their domain folder. Require only a small YAML front-matter block at the top of every deliverable:
```yaml
---
agent: folderframework-v4
domain: GHACTIONS
phase: 1
status: done
evidence:
  - path: ...
  - sha: ...
---
```
Everything after that can be free-form. This gives machines a hook while leaving prose unconstrained.

**5. Naming and discovery rules**
- Worktree naming: `wt-<domain>-<short-id>` (e.g. `wt-gha-v4`)
- Librarian `collect` should accept a list of worktree paths or a glob.
- Always write an `INDEX.md` after collection so humans and later agents can see what exists.

**6. Phase gates as checklists, not bureaucracy**
Put a short checklist in `00_CHARTER.md` (v3 already has a good one). Agents must tick it (or the synthesizer rejects the file) before a phase is considered complete. This is enough to keep quality high without micromanaging content.

**7. Generic domain handling**
Change the hard-coded lists to a config file (`swarm_config.yaml`) or command-line argument. CROSSCUTTING becomes the escape hatch for anything that doesn’t fit.

### Recommended Immediate Fixes

1. Declare `folderframework-v3` + its `swarm_librarian.py` as the canonical template.
2. Add the `validate` and `--domains` features to the librarian.
3. Write a one-page `AGENT_PROMPT.md` that every future agent must receive.
4. Move `v4`’s excellent GHACTIONS work into a proper dated SWARM structure so it matches the others.
5. Add a simple front-matter requirement.

The agents got the hard part right (isolation, phased review, evidence linking, human gate). The remaining work is mostly about making the structure *enforceable* and *generic* so later agents stop inventing their own layouts. Once the librarian + prompt contract are in place, consistency rises sharply while creativity inside each domain stays intact.
