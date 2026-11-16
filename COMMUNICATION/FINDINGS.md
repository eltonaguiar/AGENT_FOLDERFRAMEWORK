# COMMUNICATION / FINDINGS

**Date:** 2026-11-16
**Source:** Analysis of eltonaguiar/AGENT_FOLDERFRAMEWORK + multi-PC coordination needs

## Summary

The AGENT_FOLDERFRAMEWORK implements a Swarm / Isolated-Worktree Framework for multi-agent collaboration (artifacts over chat, git worktrees, phased reviews). This document adds a concrete **multi-PC communication model** so agents running on different machines (desktop, ASUS GX10, laptops, etc.) can post, mention, and coordinate without shared memory or a central chat server.

## Current Structure (unchanged)

- Root README.MD = original protocol + review.
- Versions: folderframework-v2 / v3 (cleanest scaffold) / v4 (GHACTIONS execution).
- COMMUNICATION/ is the cross-agent status and handoff folder.

## Multi-PC Agent Communication Model

The framework already treats the Git repository as the durable blackboard. Multi-PC coordination extends that idea so agents on separate machines can "post" and "mention" each other with near-zero idle cost.

### Core Principles
1. **Git is the source of truth** — every durable message, handoff, or evidence lives as a markdown (or small JSON) file that is committed and pushed.
2. **File-based mentions** — agents wake by watching for files that name them (or a role).
3. **Isolation preserved** — each agent still works in its own worktree; the only shared surface is the committed SWARM + COMMUNICATION folders.
4. **Zero-token idle** — agents sleep (or poll lightly) until a mention file appears; no constant LLM context burn.
5. **Works across Windows + Linux** — pure file + git operations; no OS-specific runtime required beyond git and a text editor/agent.

### Recommended Layout Additions
```text
COMMUNICATION/
├── FINDINGS.md                  # this file
├── BOARD.md                     # append-only shared board (latest posts at bottom)
├── mentions/
│   ├── @librarian.md              # wake the librarian
│   ├── @db-agent.md
│   ├── @gha-agent.md
│   ├── @all.md                    # broadcast
│   └── @group-reviewers.md
├── status/
│   ├── desktop-i9.heartbeat.md
│   ├── gx10.heartbeat.md
│   └── legion.heartbeat.md
└── handoffs/
    └── 2026-11-16-db-to-audit.md
```

### How Agents Post and Mention Each Other
1. **Post to the board**  
   Agent appends a short message to `COMMUNICATION/BOARD.md` (or writes a new file under `handoffs/`) and commits + pushes.

2. **Mention / wake another agent**  
   Create or overwrite a file under `mentions/@<agent-or-role>.md` containing:
   ```markdown
   --- 
   from: db-agent
   to: @librarian
   timestamp: 2026-11-16T01:50:00Z
   priority: normal
   ---
   Ghost-row analysis is in 03_DONE/DB/. Please collect and index.
   ```
   Then commit + push. The target agent (or a lightweight watcher) sees the file and wakes.

3. **Broadcast**  
   Write to `mentions/@all.md` or `mentions/@group-reviewers.md`.

4. **Heartbeat (optional but useful)**  
   Each machine periodically overwrites its `status/<machine>.heartbeat.md` with timestamp + current worktree + git SHA so others know it is alive.

### Multi-PC Transport Options (ranked)

| Rank | Method | Latency | Setup | Best for | Notes |
|------|--------|---------|-------|----------|-------|
| 1 | **Git push/pull** (canonical) | seconds–minutes | already have the repo | all durable work | Agents just `git pull` before starting and `git push` after writing. Librarian can run on any machine. |
| 2 | **Syncthing** (or Resilio) on the SWARM + COMMUNICATION folders | seconds | install on each PC, share folder | faster local iteration | File changes appear almost instantly; still commit important milestones to Git. Works Windows + Linux. |
| 3 | **Tailscale + SMB/NFS** shared drive | sub-second | Tailscale mesh + one shared volume | lowest latency | One machine exports the folder; others mount it. Agents write directly. Still push to Git for history. |
| 4 | **Lightweight watcher script** | near-real-time | tiny Python/Bash loop or inotify | automatic wake | Script on each machine watches `mentions/` and starts the appropriate agent prompt when a file for it appears. |

### Minimal Watcher Pseudocode (run on each PC)
```bash
# Example: poll every 30s or use inotifywait / watchdog
while true; do
  git pull --quiet
  if [ -f COMMUNICATION/mentions/@$(hostname).md ] || [ -f COMMUNICATION/mentions/@all.md ]; then
    # launch agent with the mention content as context
    # then move the mention file to mentions/processed/
  fi
  sleep 30
done
```

### Role Mapping Across Machines (example)
- Desktop (i9 + RTX 5070): heavy DB / prediction / local model inference agents
- ASUS GX10 (Ubuntu): librarian + evidence agent + long-running watchers
- Laptop: review / synthesis agents or mobile worktrees
- Any machine can run any role; the mention files + git are the only coordination surface.

### Zero-Token Idle Pattern
Agents stay asleep (or in a cheap local loop) until a mention file appears. When woken they:
1. `git pull`
2. Read the mention + relevant SWARM artifacts
3. Do the work in their isolated worktree
4. Write results + a new mention if needed
5. `git commit && git push`
6. Go back to sleep

This matches the Antigravity-style blackboard + @mention pattern while staying fully local and git-native.

## Other Recommendations (from prior review)
1. Declare folderframework-v3 as the canonical template.
2. Extend swarm_librarian.py with `--domains` and a `validate` subcommand.
3. Add AGENT_PROMPT.md that forces agents to use the COMMUNICATION/mentions pattern.
4. Require simple front-matter on every deliverable.

## Layout status

Created 2026-11-16 by `folderframework` after this note landed as spec-only:

- `BOARD.md`, `mentions/`, `status/`, `handoffs/`, `AGENT_PROMPT.md`, `watch_mentions.py`
- Live `@*.md` wakes are not pre-seeded. An empty file would wake every watcher. Use `status: pending` or the watcher ignores the file.
- `folderframework-v3/tools/swarm/swarm_librarian.py` already has `--domains` and `validate`. Do not re-add them.
- Do not install `iac` or Syncthing as part of this layout. Git push/pull is the transport. The watcher only pulls and prints.

## Next Steps
- [x] Create the `mentions/`, `status/`, and `handoffs/` folders.
- [x] Add `AGENT_PROMPT.md` for the post/mention protocol.
- [x] Add `watch_mentions.py` (pull + print, no auto-launch, no auto-push).
- [ ] Use `BOARD.md` and a `status: pending` mention on the next swarm run.

---
*Updated to include explicit multi-PC agent communication model (Git + file-based mentions + optional Syncthing/Tailscale).*
