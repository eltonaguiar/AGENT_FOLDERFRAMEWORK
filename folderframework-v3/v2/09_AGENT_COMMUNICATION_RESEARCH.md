# 09 — Agent communication frameworks research

```yaml
---
agent: folderframework-v3
domain: META
phase: 2
status: done
evidence:
  - url: https://github.com/Anode1/iac
    verified_at: 2026-11-16T06:44:00Z
  - url: https://github.com/fstandhartinger/agent-message-board
    verified_at: 2026-11-16T06:44:00Z
  - url: https://github.com/arvarik/bmas
    verified_at: 2026-11-16T06:44:00Z
  - url: https://github.com/jcfischer/ivy-blackboard
    verified_at: 2026-11-16T06:44:00Z
  - path: /tmp/iac-test/smoke.sh
    note: iac p2p smoke test, successful
  - path: /tmp/iac-test/smoke2.sh
    note: iac broadcast + work-queue smoke test, successful
---

Research into shared-board / blackboard-style coordination layers that could extend the folderframework-v3 swarm beyond file-only artifacts. The user pointed to Google Antigravity’s `/swarm` as the reference pattern. Includes a hands-on smoke test of `iac`.

---

## 1. The reference pattern: Antigravity `/swarm`

From the user’s description:

- A **shared, append-only, public message board** (blackboard architecture).
- The current conversation becomes the **coordinator** when `/swarm <task>` runs.
- The coordinator **splits work into non-colliding pieces** and spins up named workers (`@parser`, `@api-tests`, `@fix-1`, etc.).
- Typically adds a **verifier** (one per 2–4 workers) and an optional **monitor**.
- All communication is **public and ordered**; workers do **not** message each other privately.
- Posts use `@name`, `@group`, or `@all` mentions.
- Agents enter a **Waiting** state when idle, consuming **zero tokens** until mentioned.
- Workers often get **isolated git worktrees** so concurrent edits do not collide.
- The coordinator assigns/monitors and reports back to the user; it does not do the technical work itself.
- UI shows Board, Members (Active / Standing by / Retired), and a Graph of who mentioned whom.

This is deliberately **not** a hierarchical subagent chain. Coordination is parallel and transparent on the shared log instead of bottlenecking through one coordinator’s context.

### Why this matters for folderframework-v3
Our current swarm framework coordinates through **file artifacts** (`03_DONE/<DOMAIN>/`, `07_final_review4/`, `AGENT_PROMPT.md`, `swarm_librarian.py`). That works for plan-and-review workflows but has limits:

- No lightweight **runtime wakeup** for idle agents.
- No public **@mention** stream between parallel workers.
- No first-class **work-claiming / competing-consumers** primitive.
- No human-readable **live board** showing who is active and what they are doing.
- Coordinator burden stays inside the user’s main session.

A blackboard layer could sit *beside* the file framework: files remain the durable deliverable format; the board becomes the runtime coordination bus.

---

## 2. Candidate tools (researched)

Ordered by closeness to the Antigravity pattern: zero-token idle, shared append-only board, @mentions, local/self-hosted.

| Tool | Repo | Language / store | Match to pattern | Best for | Concerns |
|------|------|------------------|------------------|----------|----------|
| **iac** | [Anode1/iac](https://github.com/Anode1/iac) | C99 / plain-text log + `flock` | **Very high** — inotify-based `recv`, zero-token idle, `@name`/`@group`/`*`/`?`, competing consumers, presence | Single-machine fleets of coding agents; closest to Antigravity wakeup model | Same-host only; no built-in human UI; `IAC_FROM` unverified |
| **agent-message-board** | [fstandhartinger/agent-message-board](https://github.com/fstandhartinger/agent-message-board) | Python / SQLite | **High** — threads, tags, mentions, inbox, acks, read-only web UI, groups | Human visibility + agent coordination; good audit trail | `wait` polls SQLite every second; not truly zero-token idle; more overhead than `iac` |
| **bmas / Stigmergic** | [arvarik/bmas](https://github.com/arvarik/bmas) | Python/Redis/LiteLLM / SQLite journal | **High** — full blackboard multi-agent system with runtime journal, signed grants/receipts, Mission Control UI | Heavy orchestration, benchmarks, release gates | Docker stack, provider keys, AGPL-3.0; heavy for a lightweight extension |
| **ivy-blackboard** | [jcfischer/ivy-blackboard](https://github.com/jcfischer/ivy-blackboard) | TypeScript/Bun / SQLite | **Medium-high** — awareness/claiming model, work items, heartbeats, web dashboard | Work-claiming and heartbeat-driven scheduling | Bun runtime; assignment is pull/claim, not coordinator-push; no @mention stream |
| **llm_collaboration_blackboard** | [masaki-kato-119/llm_collaboration_blackboard](https://github.com/masaki-kato-119/llm_collaboration_blackboard) | Python / Markdown+YAML | **Medium** — shared workspace (plans, tasks, events, memory) via MCP or dashboard | Markdown-first, Obsidian-friendly | Less of a real-time board; more of a structured notebook |
| **Open-Swarm-ai** | [CodesbyFebin/Open-Swarm-ai](https://github.com/CodesbyFebin/Open-Swarm-ai) | Python / local-first | **Medium** — local-first stigmergy blackboard + LangGraph orchestration | Free-tier/local model setups | LangGraph dependency; newer/less proven |

### 2.1 `iac` — the closest technical match
A single dependency-free C99 binary.

- **Primitives:** `send`, `recv`, `drain`, `ask`, `join`, `hold`, `leave`, `who`, `log`, `compact`.
- **Addressing:** `*` broadcast, `name` p2p, `a,b,c` multicast, `?` competing-consumers work queue.
- **Wakeup:** `recv` blocks on `inotify` (Linux) for the room log; the child process returns when a message lands, and that return re-invokes the agent. Idle cost ≈ 0.
- **Room model:** a directory; `<room>/log` is the append-only total-order stream; `<room>/<name>.cur` is each reader’s cursor; `roster/` holds presence via `flock`.
- **Crash recovery:** `?` claims are re-runnable after `$IAC_CLAIM_TTL` if un-acked.
- **Trust:** cooperative same-host; no in-band authentication; `IAC_FROM` is a label, not identity.
- **Skill:** ships a Claude Code skill at `.claude/skills/iac/SKILL.md`.
- **License:** ISC.

Verdict: if we want to replicate Antigravity’s “parked agents wake on mention” behavior on one Linux host, `iac` is the smallest, closest fit.

### 2.2 `agent-message-board` — best human visibility
A Python CLI + SQLite board with a read-only human web UI.

- **Primitives:** threads, posts, subscriptions, inbox, acknowledgements, groups, topics, digests, snapshots.
- **Kinds:** `note`, `finding`, `question`, `answer`, `decision`, `handoff`, `warning`.
- **Addressing:** `@name`, `@job-folder`, `@group`; `humans` group for people.
- **Push:** `agent-board hook` delivers addressed/subscribed entries to running agents via hook JSON.
- **Web UI:** `agent-board web --port 8766`; read-only, HTTP Basic auth, markdown rendering.
- **License:** MIT.

Verdict: if the priority is a human-readable board with thread structure and acks, this is the strongest candidate. It is not zero-token idle, but it is lightweight and well-suited to coding-agent coordination.

### 2.3 `bmas / Stigmergic` — enterprise-grade blackboard
A Dockerized blackboard multi-agent system.

- **Stack:** Redis (locks/notifications), LiteLLM (model gateway), daemon (orchestration + runtime journal), Mission Control UI.
- **Runtimes:** Classic (control unit + blackboard), Patchboard (independent contributions + integration), Stigmergic workspace (ordered revisions to shared artifact).
- **Primitives:** immutable admissions, signed activation grants/receipts, durable runtime journal, release gates, benchmark harness.
- **License:** AGPL-3.0.

Verdict: overkill for extending folderframework-v3 today, but worth tracking if we later need benchmarks, release gates, or multi-machine coordination.

### 2.4 `ivy-blackboard` — awareness/claiming model
A TypeScript/Bun SQLite blackboard focused on work claiming.

- **Primitives:** agent/project/work-item registration, claim/release/complete/reset/block, heartbeats, events, web dashboard.
- **Philosophy:** agents see work and claim it; no central assignment.
- **Liveness:** PID checking detects crashed agents and releases claimed work.
- **License:** MIT.

Verdict: useful if we want a pull-based work queue, but does not provide the coordinator-push / @mention stream that Antigravity uses.

---

## 3. Recommendation for folderframework-v3

### Short term: integrate `iac` as an optional runtime coordination bus
Reasons:
1. **Closest to Antigravity’s zero-token idle + @mention wakeup model.**
2. **Smallest blast radius:** one C binary, one directory per swarm room, no network deps.
3. **Complements the file framework:** files remain the durable deliverables; `iac` handles runtime chatter.
4. **Already ships a Claude Code skill**, so onboarding a Kilo skill is straightforward.

### Medium term: add `agent-message-board` for human-visible threads
Use it when:
- A human needs to read the swarm discussion without scrolling a text log.
- Decisions need explicit acknowledgements from multiple agents.
- The swarm is large enough that threads and digests help.

### Not now
- `bmas` / Stigmergic — too heavy, too many moving parts, AGPL-3.0.
- `ivy-blackboard` — different model (pull/claim vs coordinator-push); revisit if we shift to fully agent-driven claiming.
- Replacing the file framework with any board — files stay canonical.

---

## 4. Integration sketch: `iac` + folderframework-v3

### Per-swarm room
```bash
export IAC_ROOM="$PWD/.iac/rooms/2026-11-16-SWARM"
export IAC_FROM="folderframework-v3"
```

### Agent lifecycle
1. On start, an agent runs `iac join "$IAC_ROOM" "$IAC_FROM"` and `iac hold` as a background beacon.
2. The agent parks on `iac recv "$IAC_ROOM" "$IAC_FROM" 300` in the background; when a message arrives, the harness wakes the agent for one turn.
3. During an active turn, the agent uses `iac drain "$IAC_ROOM" "$IAC_FROM"` to collect all addressed messages inline.
4. To broadcast a finding: `iac send "$IAC_ROOM" '*' "..."`.
5. To ask a specific worker: `iac ask "$IAC_ROOM" "@worker" "..."`.
6. To hand off a task to whoever is free: `iac send "$IAC_ROOM" '?' "..."`, then `iac ack` on completion.

### Coordinator role
The user’s main session (or a dedicated coordinator agent) becomes the coordinator by:
- Spawning workers in isolated git worktrees (already done via Agent Manager / `swarm_librarian.py`).
- Announcing tasks on the board with `@worker` or `@all`.
- Using `iac who` to check presence.
- Collecting final artifacts into `03_DONE/<DOMAIN>/` via `swarm_librarian.py collect`.

### Durable deliverables remain files
- The board is ephemeral runtime state.
- Final plans, evidence, and decisions are still committed to `03_DONE/<DOMAIN>/` and `07_final_review4/`.
- A nightly `iac compact "$IAC_ROOM"` reclaims old log frames.

---

## 5. Risks and open questions

| # | Risk / question | Mitigation |
|---|-----------------|------------|
| R1 | `iac` is same-host only. | Accept for now; cross-host coordination is not a current need. |
| R2 | `IAC_FROM` is unverified; any agent can spoof a name. | Keep same-host file permissions (`0700` rooms); do not make trust decisions based on `from` alone. |
| R3 | Adding a runtime bus creates a second source of truth. | Files remain canonical; the board is strictly transient coordination. |
| R4 | Not all agents run in a harness that supports background `recv` wakeup. | Document the pattern; fallback to `iac drain` at the top of each turn for agents that cannot park. |
| R5 | `agent-message-board` polling cost is non-zero. | Use it only where human UI / acks justify the overhead; keep `iac` for high-frequency coordination. |
| R6 | Two tools (`iac` + `agent-message-board`) could fragment the stack. | Start with `iac` only; add the second only if a human UI requirement appears. |

---

## 6. Proposed next step

1. **Pilot `iac` on one low-risk swarm mission** (e.g., the next evidence-agent pass from `08_NEXT_ACTIONS.md`).
2. **Create a Kilo skill wrapper** under `folderframework-v3/tools/swarm/` that installs `iac` and provides `swarm_iac.sh` helper commands (`send`, `recv`, `who`).
3. **Run a 2-worker + 1 coordinator smoke test** in `/tmp` and capture the transcript as evidence in `03_DONE/META/`.
4. If the smoke test succeeds, add an optional `iac` room to the `swarm_librarian.py scaffold output and document it in `AGENT_PROMPT.md`.

---

## 7. Hands-on verification of `iac`

Built from source in `/tmp/iac-test/iac-repo` (zero dependencies, C99 + make, ~74 KB binary).

### Build
```
cc -std=c99 -O2 -W -Wall -Wextra ... -o iac
/tmp/iac-test/iac-repo/iac: ELF 64-bit LSB pie executable, ARM aarch64
```

### P2P smoke test (`/tmp/iac-test/smoke.sh`)
```
[main] starting worker recv...
[main] coordinator sending task...
iac: from coordinator to worker at 1794811556
task: verify ghost-row string at dashboard_enhancements.js:829-833
[main] worker recv exit code: 0
```
A parked `recv` woke within 500 ms when the coordinator appended a message. The worker received the exact body.

### Broadcast + work-queue smoke test (`/tmp/iac-test/smoke2.sh`)
```
=== broadcast test ===
iac: from coordinator to * at 1794811561
all-hands: standup in 5
worker-a exit: 0
worker-b exit: 0

=== work-queue test ===
iac: from coordinator to ? at 1794811561 claim 52
whoever is free: check db_freshness.json consumers
worker-a claim exit: 0
```
- `*` broadcast delivered to both parked workers.
- `?` competing-consumers delivered to exactly one worker and emitted a claim id; the second worker timed out as expected.

### Verified limitations observed
- Output from concurrent receivers interleaves on stdout; a real harness should redirect each worker’s output to its own log.
- `recv` timeout must be chosen carefully: too short and idle workers burn token-less wakeups; too long and they look stale.

---

*Research completed 2026-11-16T06:44Z. Source evidence: GitHub README/pages fetched directly for the four primary tools; `iac` smoke tests run locally on aarch64 Linux.*
