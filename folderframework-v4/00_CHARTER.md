# 00 — Charter: `folderframework-v4` Swarm Deliverable

**Agent / worktree:** `folderframework-v4`
**Repo of record:** `eltonaguiar/findtorontoevents_antigravity.ca`
**Artifact store:** `eltonaguiar/AGENT_FOLDERFRAMEWORK` → `folderframework-v4/`
**Date:** 2026-11-16
**Domain owned by this worktree:** **GHACTIONS** (GitHub Actions workflow health, blast radius, site-impact, revert safety)

---

## 1. Why this subfolder exists

This is the durable, git-preserved end result of the `folderframework-v4` worktree. It follows
the phased swarm protocol in the repo root `README.MD`:

- `03_DONE/GHACTIONS/` — the completed Phase-1 deliverables, verbatim (8 analysis files + revert runbook + coordinator TODOs).
- `07_final_review4/` — the Phase-5 canonical outputs (`PLAN`, `IMPLEMENTATION_STEPS`, `TESTING_PLAN`, `FILES_TO_TOUCH`, `EVIDENCE_INDEX`).

Chat is ephemeral; this folder is the record. Every claim here is linked to a file path, commit SHA, or command in `EVIDENCE_INDEX.md`.

## 2. Scope (what this worktree investigated)

1. **Branch-trigger blast radius** — which workflows fire on `push:` / `pull_request:` and how far.
2. **Cron pile-ups** — minute-0 concentration and a deterministic stagger plan.
3. **Push-chain amplification** — schedule→push→workflow_run feedback and the stale-fork push trap.
4. **Site-impact / `/audit`** — which workflows write the live `/audit` surface and whether any resurrected deletion would add a writer.
5. **Orphans** — DB-freshness seam and the "frozen-but-plausible" sports workflows.
6. **Revert safety** — an executable runbook to undo anything the swarm lands.

## 3. Success criteria (all met)

- [x] Ghost/duplicate-workflow claim reconciled to a reproducible `git diff --name-status` over `.github/workflows/`.
- [x] Push-safety trap named and quantified (stale-fork: 88367 ahead / 15 behind; 12-row workflow delta).
- [x] `/audit` impact answered per-file, not by assertion.
- [x] Cron stagger is deterministic and semantics-preserving (`crc32 % 60`, alpha tie-break).
- [x] Revert path is copy-pasteable and verified against `origin/main` blobs.

## 4. Out of scope (explicit non-goals)

- No workflow edits were pushed. This is a **report + runbook** pass; all remediation is proposed, not applied.
- No GitHub API / DB / browser calls — findings are `git`-only and pinned to a SHA that main advances past.
- Runtime `disabled_manually` flags and live FTP-deployed files are **UNVERIFIED** (git cannot see them).

## 5. Known live URLs / key files

| Surface | Path |
|---|---|
| Audit dashboard (live) | `https://findtorontoevents.ca/audit/` and `/audit/data/dashboard_data.json` |
| Primary `/audit` writer | `.github/workflows/audit-dashboard.yml` |
| Other `/audit` writers | `deploy-competition-to-site.yml`, `deploy-fte-index.yml`, `deploy-fte-events-json.yml` |
| Churn-fix regression risk | `.github/workflows/dynamic-alpha-engine.yml` (`timeout-minutes: 90` on main) |
| Sports monitoring (frozen) | `/live-monitor/sports-betting.html` |

## 6. Agent roster (this worktree's swarm pass)

| Role | Owner | Output |
|---|---|---|
| Coordinator | `folderframework-v4` | `TODOS.md`, this charter |
| fix-manager | sub-agent | `branch_prune_list.md`, `revert_runbook.md`, `branch_capability.tsv` |
| inspector | sub-agent | `branch_trigger_audit.md` |
| queue_auditor | sub-agent | `cron_stagger_plan.md`, `push_chain_impact.md` |
| triage-expert | sub-agent | `cron_verification.md` |
| analyst-2 | sub-agent | `site_impact_audit.md`, `orphan_items.md` |

## 7. Preservation note

All ten source files were already committed to `eltonaguiar/findtorontoevents_antigravity.ca` on branch `main`
commits `ac598cefd45` and `db4cc06ed82` (both `[skip ci]`). This subfolder is a self-contained copy so the
deliverable is reproducible from the artifact repo alone, without the (fast-moving) source repo.