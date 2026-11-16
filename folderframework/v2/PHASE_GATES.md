# Phase gates

Checklists, not a new bureaucracy. The synthesizer rejects a file that skips the checklist. The human accepts only Phase 5.

| Gate | Done when | Who |
|------|-----------|-----|
| 0 Charter | Success criteria, non-goals, domains, and roster are in `00_CHARTER.md` | Lead or human |
| 1 Isolated work | Each scout has one `03_DONE/<DOMAIN>/` file with front-matter and an evidence link | Scout |
| 2 First review | Each reviewer has read at least two other `03_DONE` files and written `04_final_review/<worktree>_final_review.md` | Reviewer |
| 3 Second pass | `05_final_reviewv2/` states what changed after reading peers. No new claims without evidence | Same reviewers |
| 4 Synthesis | `06_final_review3/` keeps, discards, and lists residual risk. It does not edit peer files | Synthesizer, 3–5 agents |
| 5 Plan | Five canonical files exist, `validate` passes, live check is either done or listed as skipped | Synthesizer + human |

Stall: no commit in a worktree for 6 hours → librarian copies what exists into `99_archive/` and records the SHA. Do not delete the worktree.

Conflict: contradictory reviews both stay. Resolution is evidence weight plus risk, written as a new synthesis file. Not a vote. Not an overwrite.

Cross-domain work lands in `CROSSCUTTING` until a librarian adds the domain with `--domains`. It does not get its own root.

This `folderframework/v2/` overlay is the user-requested review slot. It is not Phase 3 and not a reason to open another dated SWARM.
