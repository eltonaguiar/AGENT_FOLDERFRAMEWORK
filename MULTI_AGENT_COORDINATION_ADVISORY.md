---
agent: subq-savant-1.4
domain: CROSSCUTTING
phase: 1
status: done
evidence: [multi_agent_coordination, ownership_plane, review_protocol]
---

# Multi-Agent Coordination — Long-Form Advisory

The normative rules live in `MULTI_AGENT_COORDINATION.md`. This document explains why
they are needed.

## Why the current setup leaks

Worktrees isolate *files*. MQTT carries *wake-ups*. Nothing owns *who-may-touch-what*.

- A worktree gives an agent its own checkout, so two agents cannot overwrite each
  other's working tree — but they still share the same DB, the same CI workflows, the
  same cron minutes, and the same origin. Isolation at the file layer creates the
  illusion of isolation everywhere.
- The bus moves messages, not state. A "handoff" message is a doorbell: by the time
  the recipient reads it, the sender may have moved on, and retained topics overwrite
  older content with newer content per topic.
- There is no ownership record anywhere, so every collision is discovered late — at
  merge, at a failed workflow, or at a corrupted table — rather than at claim time.

## The six planes

Coordination is not one problem; it decomposes into six planes that fail differently.

1. **Identity** — who is acting. Needed for attribution, review separation, and
   knowing which claim is whose. Without it, review is meaningless (see below).
2. **Workspace** — which files an agent may touch. Worktrees handle this well;
   directory-level overlap remains advisory because file-level ownership is what is
   actually enforceable.
3. **Runtime** — shared processes, ports, cron windows, DB tables. This is the plane
   worktrees do *not* isolate, and the one that produces silent corruption.
4. **Ownership** — the claim plane: who holds a file, table, or workflow right now,
   with liveness derived from heartbeats rather than asserted. Claims must be
   versioned so a resumed agent cannot clobber a successor.
5. **Integration** — the merge plane: serialized branches, rebase on current main,
   full suite on the combined tree. Individual branches being green is not evidence
   the combination is.
6. **Communication** — the notification plane: wake-ups and pointers only. Durable
   content belongs in git, per topic ownership, or it will be lost to last-writer-wins.

## Review is not enough — failure modes

A second agent reading a diff is the cheapest quality gate, and it fails in
predictable ways when the reviewer is not structurally independent:

- **Shared identity makes review worthless.** If the reviewer runs as the same
  identity as the author, approval is self-approval with extra steps — the record
  cannot distinguish who judged whom.
- **Same-model reviewers share blind spots.** A reviewer from the same model family
  tends to re-derive the author's reasoning rather than check it, so the author's
  mistake is reproduced as agreement.
- **Agents get talked out of correct answers.** A confident rationale in the PR
  description can move a correct reviewer to approve a wrong change; hence the
  review must be blind — diff and contract only, not the author's confidence.
- **Conformity collapses diversity.** When reviewers see each other's verdicts, or
  the author's framing, they converge on the majority reading even when it is wrong.
  Independence is a property of *information*, not just of instance count.

The mitigation is structural, not procedural: separate identity, different model
family where possible, blind input, an adversarial brief ("try to falsify this"),
a written contract as the standard of judgment, and a bounded loop — one round of
critique, one revision, then a verdict that escalates to a human instead of
spinning.
