# COMMUNICATION / FINDINGS

**Date:** 2026-11-16
**Source:** Analysis of eltonaguiar/AGENT_FOLDERFRAMEWORK + multi-PC coordination needs

## Summary

The AGENT_FOLDERFRAMEWORK implements a Swarm / Isolated-Worktree Framework for multi-agent collaboration (artifacts over chat, git worktrees, phased reviews). This document covers multi-PC communication: Git for durable files, and a separate messaging bus for live post/@mention/wake.

## Current Structure (unchanged)

- Root README.MD = original protocol + review.
- Versions: folderframework-v2 / v3 (cleanest scaffold) / v4 (GHACTIONS execution).
- COMMUNICATION/ is the cross-agent status and handoff folder.

## Multi-PC Agent Communication Model

The framework already treats the Git repository as the durable blackboard for files/artifacts. Messaging is handled separately so agents can post and mention each other with near-zero idle cost.

### Core Principles
1. **Git is the source of truth for files** — durable artifacts, plans, evidence, handoffs live as markdown/JSON and are committed/pushed.
2. **Messaging bus for live coordination** — @mentions, status pings, and wake signals use a lightweight pub/sub bus.
3. **Isolation preserved** — each agent still works in its own worktree.
4. **Zero-token idle** — agents sleep until a message arrives on their topic.
5. **Works across Windows + Linux**.

### File Dropping (Git)
Git push/pull remains the transport for all durable files. Agents commit results and pull before starting work.

### Messaging Bus Recommendation

**Primary recommendation: MQTT (Mosquitto) + swarmbus**

- Perfect match for Antigravity-style post / @mention / sleep-until-mentioned.
- Agents publish to topics (`mentions/db-agent`, `mentions/all`, `board/posts`) and subscribe to their own.
- Instant wake, no polling, peer-symmetric, no orchestrator.
- Extremely lightweight, excellent Windows + Linux support, works over LAN or Tailscale.
- swarmbus adds agent-friendly inbox/outbox, archiving, and wake-on-message on top of MQTT.

**Repo:** https://github.com/mpesavento/swarmbus  
**Docs:** https://swarmbus.dev

**Minimal setup**
1. Run Mosquitto on one always-on machine (GX10 or desktop).
2. `pip install swarmbus-py` (or use any MQTT client) on each agent machine.
3. Agents connect to the broker (Tailscale IP if needed).

### Comparison: MQTT/swarmbus vs Redis Bus

You previously used a Redis bus. Here is how it compares:

| Aspect | Redis Pub/Sub | Redis Streams | MQTT (Mosquitto + swarmbus) |
|--------|---------------|---------------|-----------------------------|
| **Persistence** | None (fire-and-forget) | Yes (until trimmed) | Yes (QoS 1/2 + retained messages + sessions) |
| **Wake on message** | Yes (if subscribed) | Yes (XREAD BLOCK) | Excellent (native + swarmbus wake) |
| **Missed messages while offline** | Lost | Replayable | Retained + session persistence |
| **Consumer groups / load balancing** | No | Yes | Shared subscriptions available |
| **Latency** | Extremely low | Extremely low | Very low |
| **Resource usage** | Low | Low | Very low (Mosquitto is tiny) |
| **Multi-PC / network** | Good | Good | Excellent (designed for unreliable links) |
| **Agent-specific features** | DIY | DIY | swarmbus provides inbox/outbox + archive |
| **Familiarity** | You already used it | You already used it | New but simpler for pure messaging |
| **Best for** | Simple live broadcast | Durable queues + replay | Mentions, wake, lightweight multi-machine messaging |

**Verdict**
- If you want the absolute simplest "@mention and wake me" with zero polling and minimal ops → **MQTT + swarmbus**.
- If you already have Redis running and want persistence + consumer groups in one tool you know → **Redis Streams** is excellent and a close second.
- Redis Pub/Sub alone is too lossy for reliable agent wake-ups (messages disappear if the agent is asleep).

Both work. MQTT/swarmbus is the cleaner dedicated messaging layer when Git already handles the durable files. Redis Streams is the stronger choice if you want one familiar system that can also act as a lightweight shared state store.

### Optional File-Based Mentions (fallback)
The earlier file-based `mentions/` approach still works as a pure-Git fallback, but a real messaging bus is better for live coordination.

## Other Recommendations (from prior review)
1. Declare folderframework-v3 as the canonical template.
2. `swarm_librarian.py` already has `--domains` and `validate`.
3. Use AGENT_PROMPT.md to teach agents the messaging protocol.
4. Require simple front-matter on every deliverable.

## Layout status

Created 2026-11-16:

- `BOARD.md`, `mentions/`, `status/`, `handoffs/`, `AGENT_PROMPT.md`, `watch_mentions.py`
- Live `@*.md` wakes are not pre-seeded.
- Git is the file transport. Messaging bus is separate.

## Next Steps
- [x] Create the `mentions/`, `status/`, and `handoffs/` folders.
- [x] Add `AGENT_PROMPT.md` for the post/mention protocol.
- [x] Add `watch_mentions.py` (pull + print, no auto-launch, no auto-push).
- [ ] Decide messaging bus: MQTT/swarmbus (recommended) or Redis Streams.
- [ ] Stand up the chosen bus and wire agents to it.
- [ ] Use `BOARD.md` + bus mentions on the next swarm run.

---
*Updated with messaging bus recommendation (MQTT/swarmbus vs Redis Streams) and comparison.*
