# v2 — folderframework-v3 peer cross-review & consolidated decisions

```yaml
---
agent: folderframework-v3
domain: META
phase: 2
status: done
evidence:
  - path: folderframework-v3/2026-11-16-SWARM/
    repo: eltonaguiar/AGENT_FOLDERFRAMEWORK
  - url: https://findtorontoevents.ca/audit/data/money_ready_verdict.json
    verified_at: 2026-11-16T06:19:00Z
---
```

Second-pass deliverable for worktree `folderframework-v3`, written after all four peers landed on `AGENT_FOLDERFRAMEWORK/main` and after an external review of the repo (user-provided, 2026-11-16T06:16Z).

| File | Contents |
|------|----------|
| `01_PEER_CROSS_REVIEW.md` | Per-peer review — what landed, what I independently verified (and how), defects found, verdict |
| `02_EXTERNAL_REVIEW_ADOPTION.md` | Every external issue/recommendation mapped to adopted / modified / rejected, with the concrete artifact that answers it |
| `03_FINAL_RECOMMENDATIONS.md` | Merged, prioritized recommendation set (mine + peers' + external), with owner, effort, risk |
| `04_DECISIONS_REQUIRED.md` | Decisions that need the human — options + my recommendation each |
| `05_OPEN_QUESTIONS.md` | Ambiguities that block execution if left open |
| `06_FURTHER_RESEARCH.md` | Research / discussion items, ranked |

## Verification method (what distinguishes this pass)

1. Read every peer file on `AGENT_FOLDERFRAMEWORK/main` (v1: full phase chain 00→07; v2: charter + audit report; v4: charter, PLAN, all of `07_final_review4/`; v4's 110 KB of `03_DONE/GHACTIONS/` research summarized by a read-only sub-agent — 16 internal inconsistencies flagged).
2. Re-ran peers' checkable claims against the source repo locally (`eltonaguiar/findtorontoevents_antigravity.ca`, `origin/main` = `c284ba25fe4` at check time) and the live site (three endpoints curl'd 2026-11-16T06:19Z).
3. No claim in these documents is second-hand: each either names the peer file it reviews or the command/URL I ran myself.

## Headlines

- **My scaffold is ratified as canon by the external review** ("v3 is the cleanest scaffold… declare it canonical") — with required modifications, all shipped in this drop: librarian `validate` + `--domains` + multi-`src` collect + auto-index, `AGENT_PROMPT.md` contract, front-matter spec, `swarm_domains.txt` domain config.
- **v4's two highest-severity proposals are already landed on `origin/main` by a parallel fix** (`20f6e1cdad1`, cites the GHACTIONS audit) — its plan must be rebased onto reality before any execution.
- **v1's audit-claims chain verified byte-exact** and live — it is the content authority for the DB/AUDIT pilot; my live fetch extends its window to 05:53Z (money_ready still `[]`).
- **v2's bugs are real but mostly off-charter-target** (legacy scripts wired to `live_tracker.yml`, not the canonical `/audit` pipeline); one of its three fixes is stale (already fixed 2026-06-04).
- **Live strict-JSON check passes today** (`dashboard_data.json` parses with stdlib `json`, 06:19Z) — the Infinity/NaN emission bug is not currently reproducing on production.
