# AGENT_PROMPT — mandatory preamble for every swarm agent

Every domain agent must receive this exact block. It forces placement + front-matter so
later agents stop inventing layouts. Content inside the domain folder stays free-form.

---

## Your assignment

- **Worktree:** `wt-<domain>-<short-id>` created from `origin/main` (never from a stale local clone).
- **Swarm root:** `<repo>/<YYYY-MM-DD>-SWARM/`
- **Your write path (ONLY):** `<YYYY-MM-DD>-SWARM/03_DONE/<DOMAIN>/<filename>.md`
- **Filename pattern:** `<agent_id>_<topic>.md` (e.g. `folderframework-v4_gha_stagger.md`)

## Mandatory front-matter

Every `.md` deliverable must start with:

```yaml
---
agent: <agent_id>
worktree: wt-<domain>-<short-id>
domain: <DOMAIN>
phase: 1
status: done | draft
evidence:
  - path: <repo-relative path>
    sha: <commit-or-"non-durable">
  - url: <live-url-if-used>
---
```

## Rules (hard)

1. **Do not create new top-level folders.** If you need a new domain, write it under
   `01_TODO/CROSSCUTTING/` as a request and note it in your final review; the librarian re-scaffolds.
2. **Evidence or drop.** Every claim needs a path / SHA / URL / query result.
3. **No secrets, no dumps, no generated dashboards** — markdown + redacted small JSON only.
4. **Never edit another agent's file.** Write a *new* review file instead.
5. **Tick the charter checklist** before writing any `04_final_review` file.
6. **Commit only your own files**, then ask the librarian to cherry-pick.

## Phase gates (who decides)

| From → To | Gate owner | Gate |
|---|---|---|
| 03_DONE → 04_final_review | You | Charter checklist ticked; ≥1 evidence item per claim |
| 04 → 05 | You | Re-read ≥2 peer reviews; write revised, resolved, blocked |
| 05 → 06 | Synthesizer | Merge best ideas, discard rest with reasons |
| 06 → 07 | Synthesizer + Evidence agent | Five canonical files + EVIDENCE_INDEX |
| 07 → merge | **Human / merge-agent** | Explicit approval only |

## Stall / timeout

A worktree with no commits after the charter timeout (default **6 h**) is archived by the
librarian (`99_archive/`), not deleted. Multi-day domains may set a longer timeout in the charter.

## Conflict resolution

Contradictory `final_review` files resolve by **evidence weight + risk**, never by vote.
The synthesizer records the decision and the discarded alternative in `06_final_review3/`.