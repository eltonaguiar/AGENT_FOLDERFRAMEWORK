# Multi-Agent Coordination

Normative rules for agents working concurrently on this repo. Each rule states the
requirement and the one-line reason it exists.

1. **CLAIM BEFORE EDIT.** Declare files, modules, DB tables and cron windows before
   touching them. — Overlap warnings must arrive before the first edit, which is when
   they are cheap.

2. **ADVISORY BY DEFAULT, HARD-BLOCK ONLY AT EXACT-FILE BOUNDARIES.** Directory overlap
   is a warning; a file exactly claimed by another live agent is a block. — Hard locks
   deadlock when an owner disappears.

3. **LIVENESS IS DERIVED.** A claim is live only while heartbeat `last_seen` is fresh;
   never treat a claim as durable. — A claim held by a dead agent is worse than none.

4. **VERSION EVERY WRITE.** Carry the version you last read; reject stale writes. — So a
   resumed agent cannot clobber whoever took over.

5. **ONE OWNER PER SHARED RESOURCE.** DB table, lockfile and `.github/workflows/` have a
   single owner; everyone else requests changes. Separate schema and port range per
   worktree. — Shared mutable resources are where silent corruption hides.

6. **SERIALIZE INTEGRATION.** One branch at a time into an integration branch, rebase on
   current main, run the full suite on the COMBINED tree. Refuse publish when main moved
   since base. — Green branches can still be red together.

7. **REVIEW MUST BE STRUCTURALLY DIFFERENT FROM AUTHORSHIP.** Distinct identity
   (self-approval is blocked anyway), different model family where possible, BLIND (the
   verifier sees the diff and the contract, not the author's confidence or rationale),
   ADVERSARIAL ("try to falsify this"), scoped to a written contract not taste, and
   BOUNDED: one round of critique, one revision, then a verdict that escalates rather
   than loops. — A reviewer sharing the author's priors re-derives the author's mistake.

8. **A PASSING REVIEW IS EVIDENCE, NOT PERMISSION TO MERGE.** Protected paths
   (`.github/`, schemas, migrations, secrets config) and semantic conflicts go to a
   human. — Review checks the diff against a contract, not the whole system.

9. **THE BUS IS A DOORBELL, GIT IS THE MAILBOX.** Retained topics are last-writer-wins
   *per topic*, so never share a topic for content you want to keep; the inbox carries
   wake-ups, never full artifacts or secrets. — Anything worth keeping must be
   idempotent or written down.

## Measured context

Cross-agent code pairs conflict far more often than same-agent parallel work
(41.7% vs 19.8% in a large survey). Coordination costs roughly 1.5x the agent steps
of naive shared-git operation, and it buys *agreement* rather than *correctness* —
a coordinated fleet is not a correct fleet. The practical ceiling is 3-5 concurrent
agents before merging, not writing, becomes the bottleneck.
