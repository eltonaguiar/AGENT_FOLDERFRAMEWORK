# Layout contract

Status: proposed. Not applied to peer folders. Observed at `86df7cd`.

## What is inconsistent now

| Tree | Layout defect |
|------|----------------|
| `folderframework-v2/` | `00_CHARTER/` is a folder, not `00_CHARTER.md`. No phase folders. |
| `folderframework-v3/2026-11-16-SWARM/` | Matches the protocol. Phase-5 files are empty templates. |
| `folderframework-v4/` | Charter, `03_DONE/`, and `07_final_review4/` sit directly under the worktree folder. No dated SWARM root. |
| `folderframework/v2/` and `folderframework-v4/v2/` | Review overlays the user asked for. Not a swarm root. Do not copy this pattern for domain work. |

`folderframework-v3/tools/swarm/swarm_librarian.py` hard-codes domains at lines 20–21 (`DB`, `GHACTIONS`, `AUDIT`, `PREDICTION`, `CROSSCUTTING`). `03_DONE` omits `CROSSCUTTING`. There is no `validate` subcommand and no `--domains` flag.

## Allowed structure

One dated root per swarm: `YYYY-MM-DD-SWARM/`.

```text
YYYY-MM-DD-SWARM/
  00_CHARTER.md
  01_TODO/<DOMAIN>/
  02_IN_PROGRESS/
  03_DONE/<DOMAIN>/
  04_final_review/
  05_final_reviewv2/
  06_final_review3/
  07_final_review4/
  99_archive/
  evidence/<DOMAIN>/
  INDEX.md
```

Worktree identity stays the parent folder (`folderframework-v4/`), not a second layout inside it.

## Rules

- New swarm folders are created only by `swarm_librarian.py scaffold`.
- Domains come from `--domains` or `swarm_config.yaml`. `CROSSCUTTING` is the escape hatch, not a prompt to fork the tree.
- Agents do not create top-level folders. A missing domain is a note in `CROSSCUTTING` plus a librarian request.
- Deliverable name: `<worktree>_<topic>.md`.
- Raw command output, JSON snippets, and screenshots go in `evidence/<DOMAIN>/`. Markdown links to them. No dumps in the plan body.
- `07_final_review4/` must contain `PLAN.md`, `IMPLEMENTATION_STEPS.md`, `TESTING_PLAN.md`, `FILES_TO_TOUCH.md`, `EVIDENCE_INDEX.md`.
- Do not move another agent's files to "fix" layout. Librarian copies with a pointer to the source SHA. v4's GHACTIONS docs stay where they are until that copy is requested.
- A new dated SWARM starts when the charter date, scope, or domain set changes. Same-day additions append. They do not open a second root.

## Front-matter (new files only)

```yaml
---
agent: folderframework
domain: CROSSCUTTING
phase: 2
status: done
evidence: []
---
```

Do not retrofit peer files in this pass.

## Validate (not built here)

`validate` should fail if a required phase folder or any of the five final files is missing, if a `03_DONE` file has no evidence link, or if a file sits outside the tree. It should warn, not delete. Run it before a librarian merge. Implementing it belongs in v3's script after D8, not in a third copy.
