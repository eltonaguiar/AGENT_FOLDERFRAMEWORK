# 09 — Agent communication frameworks (blackboard / `/swarm` research)

**Author:** `folderframework-v4` · **Date:** 2026-11-16 · **Ask:** consider agent-communication frameworks and research Google Antigravity's `/swarm` model.
**Bottom line:** Antigravity's `/swarm` = **(isolation + durable artifacts)** + **(a real-time append-only blackboard)** + **(verifier/monitor roles)**. The folderframework already has the first; it is missing the second and third. Layer **`iac`** (or `agent-message-board`) under it and add a **verifier** role. Do **not** rebuild what these tools already do.

---

## 1. Antigravity `/swarm` — verified (not hearsay)

Confirmed against primary sources (not the prompt alone):
- **Docs:** `https://antigravity.google/docs/swarm/` and `/docs/subagents/` — `/swarm` turns the conversation into a **coordinator** that splits non-colliding work, spawns **named workers** (`@parser`, `@api-tests`, `@fix-1..4`), adds a **`@verifier` per 2–4 workers**, and an optional **`@monitor`**.
- **Board:** one **shared, append-only** board; posts addressed `@name` / `@group` / `@all`; workers **do not** DM privately; idle workers **sleep at zero tokens** and wake on mention. Board UI = **Board / Members / Graph** (Alt+S / `/swarm board`).
- **Isolation:** workers run in **isolated git worktrees** (and inherit staged/unstaged/untracked changes — `CHANGELOG.md` 1.5.5).
- **Models/quota:** workers can run on **any `/model`**; a worker out of quota **pauses** (does not auto-retry).
- **Lineage:** classic **blackboard / Hearsay-II (1970s)** pattern, rediscovered for LLM agents.

So the prompt's description is accurate. The only correction: the board is a coordination log (ephemeral-ish posts), whereas a *durable* artifact store (our dated SWARM folders) is a separate concern — they are complementary, not the same thing.

---

## 2. The six repos — all real, verified from their READMEs

| Tool | What it actually is (from README) | License | Local-first fit |
|---|---|---|---|
| **Anode1/iac** | Tiny **C99** binary; plain-text **append-only log** per room; `recv` blocks on **inotify** (zero-token idle); addressed / `*` broadcast / `a,b` multicast / **`?` competing-consumer work-queue** with TTL claim recovery; `flock` presence (`who`); `drain`, `ask`, `compact`; ships a Claude Code skill; Zenodo paper. **Same host / shared FS only; no auth** (cooperative, filesystem perms). | ISC | **Best match** — model-agnostic, ~zero cost |
| **fstandhartinger/agent-message-board** | **Python stdlib + SQLite** board; **threads, tags, @mentions, @groups, inbox, acks, digest**; **`hook`** pushes new entries into running Claude Code/Codex/Devin; read-only **web UI** (Basic auth). | MIT | High — structured + human visibility |
| **arvarik/bmas (Stigmergic)** | Full **self-hosted platform**: Docker Compose (Redis, LiteLLM, daemon w/ **append-only runtime journal + signed grants/receipts**, Next.js **Mission Control**). Runtimes: **Classic** (control unit + blackboard), **Patchboard** (independent contributions + integration), **Stigmergic workspace** (ordered revisions to one artifact). **Hermes execution nodes**, optional vLLM GPU. | **AGPL v3** | High capability, heavy; Hermes-aware |
| **jcfischer/ivy-blackboard** | **Bun/TS + SQLite**; **awareness model** (agents **claim**, not assigned); heartbeats, PID-liveness stale detection, age-aware priority scoring, web dashboard + SSE; part of a hub/spoke (`pai-collab`). | MIT | Medium — work-claiming focus |
| **masaki-kato-119/llm_collaboration_blackboard** | **Python**, Markdown + YAML front-matter; **plans / tasks (claim·update·cancel·recover) / audit events / memory / state**; **MCP server + dashboard**. | MIT | Medium — plan/task/audit persistence |
| **CodesbyFebin/Open-Swarm-ai** | **Python**, local-first; **LangGraph** orchestration + **stigmergy blackboard**; router **Ollama → free-tier fallback**; **real HITL** (`interrupt()`); SSE dashboard; Docker sandbox (design). | MIT | High intent, **early alpha** |

> Note: GitHub *search* returned 0 for these (API indexing), but all six resolve and were read directly. None is a Google product; they are independent OSS.

---

## 3. Evaluation against what `/swarm` gives you

| Requirement | iac | agent-message-board | bmas | ivy-blackboard | llm_collab_bb | Open-Swarm |
|---|---|---|---|---|---|---|
| Append-only shared board | ✅ | ✅ | ✅ | ✅ | ✅ (md) | ✅ |
| `@name`/`@group`/`@all` | ✅ | ✅ | roles | ❌ | ❌ | ❌ |
| **Zero-token idle → wake on mention** | ✅✅ inotify | ✅ (wait/hook) | ~ daemon | ~ heartbeat | ❌ | ❌ |
| Isolated worktrees | coord only | jobdir | ❌ | ❌ | ❌ | ❌ |
| Local / free-tier / Ollama·vLLM·Hermes | ✅ agnostic | ✅ agnostic | ✅ LiteLLM/Hermes/vLLM | ✅ agnostic | ✅ agnostic | ✅ Ollama/free |
| Human visibility (board UI) | ❌ (text/`who`) | ✅✅ web UI | ✅✅ Mission Control | ✅ dashboard+SSE | ✅ dashboard | ✅ dashboard |
| Durable structured artifacts | log | threads/acks | journal | SQLite | ✅ plans/events | blackboard |
| Lightweight / low effort | ✅✅ one binary | ✅ pip | ❌ Docker stack | ✅ bun | ~ python | ~ python |
| Verifier/review loop | role | acks/decision | ✅ Classic/Patchboard | ❌ | reviewer role | ✅ critic |
| Multi-host | ❌ (shared FS) | ❌ | ✅ (deploy) | hub/spoke | ❌ | ❌ |

---

## 4. Recommendation for this setup (local-first: Ollama / vLLM / Hermes / OpenClaw)

**Tier 1 — pilot now (days):** `iac`.
- It is the closest 1:1 to Antigravity's mechanism: append-only room + `@`-addressing + **sleep-until-mentioned** (`recv` on inotify) + `?` work-queue. One C99 binary, ISC, model-agnostic — works with any of your runners.
- Pair it with the folderframework: **`iac` room = live channel; dated SWARM folders = durable record.** iac's log is also greppable, so for a small fleet it can *be* the record.

**Tier 1 alternative (if you want threads + a human web UI):** `agent-message-board`. SQLite + threads/tags/acks + read-only UI + `hook` push. Slightly more structure, still stdlib-only.

**Tier 2 — if you want an orchestrator/router + HITL:** `Open-Swarm` (Ollama-first, LangGraph, real approval gates) — but it's **alpha**; treat as a spike, not a dependency.

**Tier 2 — if you want a full platform + benchmarks + Hermes nodes:** `bmas/Stigmergic` — most capable, but **AGPL** and Docker-heavy; adopt only if you want the benchmark/eval machinery.

**Specialist:** `ivy-blackboard` (claim-a-work-item pools), `llm_collaboration_blackboard` (plan/task/audit-event persistence via MCP).

**Explicit non-goal:** do not build a custom message bus. The `folderframework` + `iac` combination already covers "live coordination + durable artifacts."

---

## 5. How this changes the folderframework (concrete)

Add a **`comms/` layer** and two roles, mirroring `/swarm`:

| Add | Maps to Antigravity | Implementation |
|---|---|---|
| **Live board** | shared append-only board | run one `iac` room (e.g. `/swarm/2026-11-16`) for the swarm's duration |
| **Wake-not-poll** | idle = 0 tokens | agents park `iac recv <room> <name> &`; the C child wakes the harness on mention |
| **Verifier role** (1 per 2–4 workers) | `@verifier` | a worktree that reads diffs, runs tests, posts results to the worker on the board |
| **Monitor role** | `@monitor` | a stall detector: posts only if all workers go quiet before done (ties to the framework's existing "no commit in N hours → archive" rule) |
| **Work-queue dispatch** | coordinator assigns | `iac send <room> '?'` hands a job to one free worker (competing consumers), crash-recoverable via TTL |
| **Durable record** | (our addition) | SWARM folders unchanged — the board is the *live* log; the folders are the *canonical* artifact |

This is the missing half of the framework: today agents coordinate via chat + git commits (slow, no wakeup); `iac` adds the low-latency channel, and the verifier/monitor roles add the adversarial review + stall recovery `/swarm` is known for.

---

## 6. Suggested next step + decision

**Pilot (low risk, 1 day):** stand up `iac` on a throwaway room, run **two** workers (e.g. `wt-gha` + `wt-audit`) + **one verifier**, and have them coordinate a small task entirely via the board while writing artifacts into a dated SWARM folder. Measure: (a) tokens spent idle vs the current poll/chat pattern, (b) whether the verifier catches anything the workers missed.

**Decision for the human:**
- **C1.** Adopt `iac` as the live board for swarms? (my rec: **yes**, pilot first)
- **C2.** Add the **verifier** + **monitor** roles to the folderframework protocol? (my rec: **yes** — 1 verifier per 2–4 workers)
- **C3.** Prefer `iac` (lean) or `agent-message-board` (threads + web UI) as the standard? (my rec: **iac** for zero-token; agent-message-board if a human wants to watch a board)
- **C4.** Any constraint against AGPL (`bmas`) or alpha deps (`Open-Swarm`)? (affects Tier-2 only)

---

## 7. Evidence index (this file)
- Antigravity docs: `antigravity.google/docs/swarm/`, `/docs/subagents/`; CLI changelog `github.com/google-antigravity/antigravity-cli` (1.5.5: `/swarm`, `/swarm board`, alt+s, worktree change carry-over).
- `github.com/Anode1/iac` (README; ISC; Zenodo DOI 10.5281/zenodo.21206970).
- `github.com/fstandhartinger/agent-message-board` (README; MIT).
- `github.com/arvarik/bmas` (README; AGPL v3; Hermes nodes).
- `github.com/jcfischer/ivy-blackboard` (README; MIT; Bun/SQLite).
- `github.com/masaki-kato-119/llm_collaboration_blackboard` (README; MIT; MCP).
- `github.com/CodesbyFebin/Open-Swarm-ai` (README; MIT; alpha).
- All six READMEs read directly via GitHub API on 2026-11-16.