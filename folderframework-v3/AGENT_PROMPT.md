# AGENT_PROMPT.md — mandatory contract for any agent working a SWARM drop

> Hand this verbatim to every agent (scout, reviewer, synthesizer, evidence, librarian) alongside its task prompt. Framework reference: repo-root `README.MD`. Canonical tooling: `folderframework-v3/tools/swarm/swarm_librarian.py`.

## 1. Placement rules (non-negotiable)

- Write **only** inside `<YYYY-MM-DD>-SWARM/` of your assigned subfolder in `eltonaguiar/AGENT_FOLDERFRAMEWORK` (subfolder name = your worktree name).
- Phase 1 findings go to `03_DONE/<DOMAIN>/`, optionally grouped in a run-stamped subfolder (`YYYY-MM-DD_HH-MM-SS_<TZ>_<domain>/`) — the pattern proven by `folderframework-v4`.
- Intermediate notes go to `02_IN_PROGRESS/`; delete or promote them before your drop closes.
- **Do not create new top-level folders.** Need a new domain? Write it under `CROSSCUTTING/` and ask the librarian to re-scaffold: `swarm_librarian.py scaffold --domains DB,GHACTIONS,...,NEWDOMAIN`.
- Filenames: `<worktree>_<topic>.md` (e.g. `folderframework-v3_peer-crossreview.md`).

## 2. Required front-matter on every 03_DONE deliverable

```yaml
---
agent: <worktree name>
domain: <one of swarm_domains.txt>
phase: 1
status: done | in_progress | blocked
spans: [<other domains if crosscutting>]
evidence:
  - path: <repo-relative path>
  - sha: <commit SHA, if applicable>
  - url: <live URL, if applicable>
  - verified_at: <UTC ISO timestamp>
---
```

Everything after the front-matter is free-form prose. The librarian's `validate` warns on missing front-matter; `--strict` fails.

## 3. Evidence rule

Every claim must carry a path, commit SHA, live URL, or pasted query+result. Reviews without evidence are invalid. **Never cite volatile paths** (`/tmp/...`) as evidence — commit small (≤256 KB) redacted JSON/log excerpts into the top-level `evidence/<DOMAIN>/` folder and link them from your deliverable (pattern proven by v4's `branch_capability.tsv` sidecar). No secrets, `.env`, full DB dumps.

## 4. Phase gates (checklists, not bureaucracy)

- Before writing `04_final_review/`: tick the checklist in `00_CHARTER.md §6` (cited evidence, reviewed ≥2 peers, checked live surfaces, checked local diffs/commits, no secrets).
- Before `07_final_review4/` opens: all five canonical files exist as drafts; `swarm_librarian.py validate --dir <swarm>` exits 0.
- A phase is "done" when the librarian's `validate` passes **and** the checklist ticks are in the file, not when an agent feels done.
- Contradictions between agents: never edit a peer's floor. Write an errata in *your* subfolder (`<worktree>_errata_<topic>.md`); the synthesizer resolves in `06_final_review3/` by evidence weight + risk, and must cite both sides.

## 5. Isolation + git safety

- One worktree per agent; artifact subfolder name == worktree name.
- Never force-push. On push rejection: `git fetch origin && git rebase origin/main && git push` (subfolders are disjoint; rebase is clean). Cherry-pick only on real conflicts.
- Never run `git push --force`, `git reset --hard`, `git clean -fd`, or delete branches without human sign-off.
- In the *source* repo: never `git add .github/workflows/` wholesale (stale-fork trap); stage docs file-by-file; `origin/main` advances ~1 commit/min — re-fetch before any delta claim.

## 6. Dated-folder policy

- Start a new dated SWARM root when the **charter date, scope, or domain set changes**; same-day additions to an unchanged charter append to today's folder (rule from `folderframework/v2/LAYOUT_CONTRACT.md`, adopted). Do not reopen archived drops (`99_archive/`).
- Agents never edit another agent's subfolder in `AGENT_FOLDERFRAMEWORK`, including "fixing" their layout. Structural migrations are librarian-or-human decisions; the safe pattern is copy-with-source-SHA, never move.
