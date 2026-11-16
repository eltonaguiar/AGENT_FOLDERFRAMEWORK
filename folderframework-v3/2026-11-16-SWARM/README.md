# 2026-11-16-SWARM — dated artifact folder

> **Note (2026-11-16, second pass):** `07_final_review4/*.md` here are **unfilled templates by design** — this worktree's drop-1 scope was framework scaffolding, not domain findings. Both peers (`folderframework/v2/PEER_REVIEW.md`, `folderframework-v4/v2/01_PEER_REVIEW.md §C`) correctly flagged that these must not be read as a plan. This agent's actual findings live in `folderframework-v3/v2/`.

Implements the **Swarm / Isolated-Worktree Framework** (see repo-root `README.MD`). Phases:

| Phase | Where | Who | Output |
|-------|-------|-----|--------|
| 0 – Charter | `00_CHARTER.md` | human / lead agent | scope, success criteria, roster |
| 1 – Isolated attempts | `01_TODO/` → `02_IN_PROGRESS/` → `03_DONE/` | domain agents in own worktrees | findings `.md` + small evidence `.json` |
| 2 – First peer review | `04_final_review/` | every agent reviews self + ≥2 others | `agent_X_final_review.md` |
| 3 – Second pass | `05_final_reviewv2/` | same agents, shorter | revised recs, resolved disagreements, blockers |
| 4 – Subset synthesis | `06_final_review3/` | 3–5 strongest + synthesizer | single consolidated doc |
| 5 – Final verification | `07_final_review4/` | synthesizer + evidence agent | PLAN / IMPLEMENTATION_STEPS / TESTING_PLAN / FILES_TO_TOUCH / EVIDENCE_INDEX |
| — | `99_archive/` | librarian | dead worktrees' salvageable notes |

Rules that bite if ignored:

- **Evidence-linked**: every claim cites a file path, commit SHA, live URL, or query result. No-evidence reviews are invalid.
- **No silent overwrites**: never edit another agent's file; write a new review file instead.
- **Markdown + small JSON only** in this folder tree — no `.env`, keys, DB dumps, or generated dashboards.
- **Final_review4 is a plan**, not an automatic merge. A human / designated merge agent decides what lands.

Tooling: `../tools/swarm/swarm_librarian.py` (`scaffold` / `collect` / `index`).
