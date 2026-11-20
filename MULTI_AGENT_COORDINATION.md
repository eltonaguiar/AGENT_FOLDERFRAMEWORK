# Multi-Agent Coordination

This repo owns the **artifact and coordination protocol**: where deliverables go,
how worktrees are named, how agents are isolated, and how work is handed off.

Behaviour rules — how an agent should reason, review, or ask before acting — do
**not** live here. They live in each agent's own rules file. See
[`RULES_LAYER.md`](RULES_LAYER.md) for which file each tool reads and why a rules
file is context rather than enforcement.

The long-form reasoning behind these rules is in
[`MULTI_AGENT_COORDINATION_ADVISORY.md`](MULTI_AGENT_COORDINATION_ADVISORY.md).

## 1. Placement — where artifacts go

One dated SWARM folder per effort, on a dedicated branch:

```text
YYYY-MM-DD-SWARM/
├── 00_CHARTER.md          # scope, success criteria, non-goals, agent roster
├── 01_TODO/<DOMAIN>/
├── 02_IN_PROGRESS/
├── 03_DONE/<DOMAIN>/      # finished individual deliverables
├── 04_final_review/
├── 05_final_reviewv2/
├── 06_final_review3/
├── 07_final_review4/      # PLAN.md, TESTING_PLAN.md, IMPLEMENTATION_STEPS.md,
│                          # FILES_TO_TOUCH.md, EVIDENCE_INDEX.md
└── 99_archive/
```

Rules:

- **Scaffold, don't improvise.** Create the folder with
  `swarm_librarian.py scaffold` so every swarm has the same shape. Domains are
  configurable (`--domains DB,GHACTIONS,AUDIT,...`); `CROSSCUTTING` is the escape
  hatch for anything that does not fit an existing domain.
- **No new top-level folders.** If you need a domain that does not exist, note it
  in `CROSSCUTTING` and request a librarian run.
- **Filename pattern:** `<agent_or_worktree>_<topic>.md`.
- **Front-matter on every deliverable** — the machine-readable hook that lets the
  librarian index your file while the prose stays free-form:

  ```yaml
  ---
  agent: <agent id>
  domain: <DOMAIN>
  phase: <n>
  status: draft | done
  evidence:
    - path: ...
    - sha: ...
  ---
  ```

- **Evidence-linked or it is not a deliverable.** Every claim points to a file
  path, commit SHA, live URL, or query result.
- **Raw evidence does not pollute the markdown.** Put command output, JSON
  snippets and screenshots beside the note (or in `99_archive/`) and link them.
- **Never commit secrets.** No `.env`, keys, or full database dumps — redacted
  evidence only.
- **Clean up.** `git worktree prune` when the swarm ends; the SWARM folder stays
  on its own branch so it can be merged or discarded cleanly.

## 2. Isolation — worktree, port, schema

Worktrees isolate *files*. They do not isolate the database, the ports, or the
cron minutes. Isolate all four explicitly.

| Plane | Mechanism | Default |
|-------|-----------|---------|
| Files | one `git worktree` per agent | `wt-<domain>-<short-id>` |
| Ports | per-worktree port range | assign a distinct range before starting a server |
| DB schema | per-worktree schema or database name | never share a mutable table across live agents |
| Cron / CI minutes | declared schedule window | stagger; one owner per `.github/workflows/` file |
| Integration | one branch at a time into the integration branch | rebase on current main, run the suite on the COMBINED tree |

- **Worktree naming:** `wt-<domain>-<short-id>` (e.g. `wt-gha-v4`). The librarian
  discovers worktrees by that pattern.
- **One owner per shared resource.** A DB table, a lockfile, or a workflow file
  has exactly one owner at a time; everyone else requests changes from the owner.
- **Never force-push.** Use `git worktree add` so the main checkout stays clean.
- **Refuse to publish when main moved since your base.** Rebase first, re-run the
  suite, then push.

## 3. Handoff — the envelope

A handoff is a written artifact, not a vibe. Every handoff message carries:

1. **Target file(s)** — exact paths the recipient should read or edit.
2. **Raw error** — the verbatim output, not a paraphrase or a summary.
3. **Reproduction command** — the exact command, from the exact directory, that
   reproduces the state.
4. **What is blocked** — what you could not finish and why, so the recipient
   knows where to start.

Keep it short and factual. Do not include your confidence, your rationale, or a
recommendation disguised as a finding — the recipient re-derives the judgment
from the evidence.

## 4. Bus vs git

**The bus is a doorbell. Git is the mailbox.**

- **Durable content goes in git.** Plans, evidence, diffs, handoff envelopes,
  anything you want to survive — commit it.
- **The bus carries wake-ups only.** A message on the bus is a pointer: "read
  `03_DONE/AUDIT/x.md`". It is never the artifact itself.
- **Retained topics are last-writer-wins *per topic*.** Two messages on the same
  topic means the second silently replaces the first. Never share a topic for
  content you want to keep, and never assume a retained message is still the one
  you sent.
- **Inbox is per agent** — `inbox/<host>/<worktree>/<agent>` — plus the subtree
  broadcast `inbox/<host>/<worktree>/all` and `mentions/all`. Subscribe narrowly;
  a wide subscription wakes on every sibling message.
- **Never put secrets or full artifacts in a payload.** The guard refuses common
  key shapes, but the guard is a filter, not a guarantee.
- **Liveness is retained state, not a claim:** `status/<host>/<worktree>/<agent>`.

## Measured context

Cross-agent code pairs conflict far more often than same-agent parallel work
(41.7% vs 19.8% in a large survey). Coordination costs roughly 1.5x the agent steps
of naive shared-git operation, and it buys *agreement* rather than *correctness* —
a coordinated fleet is not a correct fleet. The practical ceiling is 3-5 concurrent
agents before merging, not writing, becomes the bottleneck.
