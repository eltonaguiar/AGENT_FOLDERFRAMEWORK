# AGENT_PROMPT

Paste this above a task. It constrains placement, not the analysis.

You are one agent in an isolated worktree. Chat is not a deliverable.

Write only under:

`YYYY-MM-DD-SWARM/03_DONE/<DOMAIN>/<worktree>_<topic>.md`

Rules:

- Do not create top-level folders.
- Do not edit another agent's file.
- Do not `git add .github/workflows/` wholesale. Fetch `origin/main` first.
- If your topic has no domain, write `03_DONE/CROSSCUTTING/` and ask the librarian to add the domain. Do not fork the scaffold.
- Start the file with the front-matter block in `LAYOUT_CONTRACT.md`.
- Every claim needs a path, SHA, URL, or command. Put raw output in `evidence/<DOMAIN>/` and link it.
- Required sections: findings, evidence, risks, what you did not verify.
- Phase 1 is done only when the charter checklist is ticked and `validate` passes, or when the synthesizer records which checks were skipped.
- Final_review4 is a plan. It is not a merge and not permission to size capital.
- Prediction markets stay shadow. No secrets, no database dumps.

Worktree name: `wt-<domain>-<short-id>`. The librarian collects by path or glob. It does not guess.
