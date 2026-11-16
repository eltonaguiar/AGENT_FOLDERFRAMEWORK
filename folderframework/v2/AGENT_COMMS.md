# Agent communication — research note

Cross-machine board is `COMMUNICATION/` in this repo. Protocol: `COMMUNICATION/AGENT_PROMPT.md`. Watcher: `COMMUNICATION/watch_mentions.py` (pull and print only).

Checked 2026-11-16 against GitHub, not against a running install. This does not adopt a new board.

## What Antigravity `/swarm` is

A coordinator splits work. Workers post on one append-only board with `@name` mentions. Idle workers are not polled. Worktrees keep edits apart. That is the same shape this swarm already used: isolated worktrees plus `AGENT_FOLDERFRAMEWORK` as the durable log. Kilo also has a session board (`board_post` / `board_read`) that wakes on mention. Do not add a second board for agents that already have that.

## Tools that exist

| Repo | Stars | Last push | Fit |
|------|-------|-----------|-----|
| [Anode1/iac](https://github.com/Anode1/iac) | 2 | 2026-11-03 | Closest to zero-token idle. One C binary, plain-text log, `recv` wakes on inotify. ISC. |
| [fstandhartinger/agent-message-board](https://github.com/fstandhartinger/agent-message-board) | 17 | 2026-10-31 | SQLite board, mentions, human read-only UI. |
| [arvarik/bmas](https://github.com/arvarik/bmas) | 5 | 2026-09-14 | Fuller blackboard with signed grants. Heavier than this swarm needs. |
| [jcfischer/ivy-blackboard](https://github.com/jcfischer/ivy-blackboard) | 2 | 2026-03-30 | SQLite claim/heartbeat board. Stale relative to the others. |
| [masaki-kato-119/llm_collaboration_blackboard](https://github.com/masaki-kato-119/llm_collaboration_blackboard) | 0 | 2026-08-20 | Markdown workspace. Not a wakeup bus. |
| [CodesbyFebin/Open-Swarm-ai](https://github.com/CodesbyFebin/Open-Swarm-ai) | 0 | 2026-10-04 | LangGraph plus a blackboard. Extra orchestrator. |

Stars are not a quality score. They are a warning that none of these is a maintained fleet standard.

## Recommendation

Pause adoption. The failure mode in this swarm was layout drift and uncited claims, not missing chat. A new binary does not fix that.

Use `iac` only if a human wants non-Kilo agents (Ollama, OpenClaw, Hermes) on this machine to sleep until mentioned. Do not point it at the trading repo as a commit path. Keep durable findings in `AGENT_FOLDERFRAMEWORK/<worktree>/`. Keep code edits in isolated worktrees.

Do not install `iac`, SQLite boards, or LangGraph as part of the display PR.
