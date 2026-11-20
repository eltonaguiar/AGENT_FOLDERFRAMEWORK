# Rules Layer — behaviour lives with each agent

This repo ([`MULTI_AGENT_COORDINATION.md`](MULTI_AGENT_COORDINATION.md)) owns the
**artifact and coordination protocol**: where deliverables go, worktree naming,
isolation, handoff envelopes, and how agents wake each other.

**Behaviour rules are a different layer, and they do not live here.** Each agent's
own rules file owns how it reasons, reviews, and asks before acting.

## Which file each tool reads

Agents do not read each other's rules files. Each tool opens its own:

| Tool | Rules file it opens |
|------|--------------------|
| Cursor | `AGENTS.md` or `.cursor/rules/*.mdc` |
| Claude Code | `CLAUDE.md` |
| Codex | `AGENTS.md` |
| Copilot | `.github/copilot-instructions.md` |
| Gemini CLI | `GEMINI.md` |

`AGENTS.md` is the closest thing to a shared front door (it is the Linux
Foundation-backed convention), and `CLAUDE.md` falls back to it only when it is
absent. That is still not one file everyone natively reads.

**Recommended pattern: one canonical file plus thin pointers.** Write the real
rules once, then make every other file a two-line pointer — "behaviour rules live
in `<canonical>`; read it" — rather than copying the text. Copies drift; pointers
do not.

## A rules file is context, not enforcement

A rules file is concatenated into the same context window as the task and competes
with it for attention. It has no veto: nothing in the execution path consults it.
Agents have force-pushed past a rules file that said "ask before any push"
because the file was advice and the shell was not gated.

So:

- A rules file shapes *default* behaviour. It does not guarantee anything.
- **Anything that must be guaranteed belongs in a hook, a permission gate, or a
  CI check** — something that runs in the execution path and can refuse.
- When you find yourself strengthening a sentence in a rules file to prevent a
  repeat of an incident, add the check instead (or as well).

## Reference set — behavioural rules an agent's own rules file may adopt

The following is a **reference**, not something this repo enforces. Adopt it into
your own rules file (or the canonical file your tool reads) if it fits.

### Before acting

- Read the task and the surrounding code before writing anything.
- Prefer a reversible action (`trash` over `rm`, a branch over a force-push).
- Ask before anything that leaves the machine or destroys state.

### During work

- Verify with the real invocation the production path uses, not an approximation.
- Keep changes scoped to the request; do not refactor adjacent code unasked.
- Write down what you decided and why — in a file, not in your head.

### Before claiming done

- Run the verification command and read its output. Evidence before assertions.
- State what you did *not* verify.
- If a check fails, say so plainly instead of softening it.

### Review

- Review must be structurally different from authorship: distinct identity,
  different model family where possible, blind (diff and contract only — not the
  author's rationale or confidence), adversarial ("try to falsify this"), scoped
  to a written contract rather than taste, and bounded (one round of critique, one
  revision, then a verdict that escalates rather than loops).
- A passing review is evidence, not permission to merge. Protected paths and
  semantic conflicts go to a human.

### Memory

- "Mental notes" do not survive a restart. If it matters, write it to a file.

---

If you want a guarantee behind any of the above, put it in a hook, a permission
gate, or a CI check. This page cannot enforce itself either.
