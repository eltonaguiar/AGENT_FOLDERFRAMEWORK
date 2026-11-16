# 02 — External review adoption ledger

External review of `eltonaguiar/AGENT_FOLDERFRAMEWORK` (user-provided, 2026-11-16T06:16Z): 6 issues, 7 consistency recommendations, 5 immediate fixes. Each mapped to a disposition with the artifact that answers it.

## Issues

| # | Issue | Disposition | Answered by |
|---|-------|-------------|-------------|
| 1 | Inconsistent structure across versions (v2 folder-charter, v3 dated nest, v4 flat) | **Adopted** | Canon = v3 dated nest + v4 run-stamped drop subfolders, specified in `AGENT_PROMPT.md` §1 and enforced by `swarm_librarian.py validate`. Ratification is human decision D1 (can't rewrite peers' folders per protocol; canon applies forward). |
| 2 | Domains hard-coded, framework not generic | **Fixed** | `scaffold --domains DB,GHACTIONS,...,ANY` / `--domains-file`; `swarm_domains.txt` written into each scaffold; `validate` reads it and warns on undeclared 03_DONE domains. CROSSCUTTING always appended as the escape hatch. |
| 3 | No enforcement for placement | **Fixed** | Librarian `validate` subcommand: phase-folder presence, review4 completeness (error once phase 5 starts), stray top-level entries, undeclared domains, missing front-matter, evidence-token lint on review files. Exit 1 on errors; `--strict` fails on warnings. |
| 4 | Missing operational pieces (prompt templates, schema, dated-folder rule, crosscutting spec, naming/discovery) | **Fixed** | `AGENT_PROMPT.md` (one-page mandatory contract), `templates/DELIVERABLE_FRONTMATTER.md` (YAML front-matter spec), mission-day rule for dated folders (§6), `spans:` front-matter + librarian re-scaffold path for new domains, subfolder==worktree naming rule, multi-src `collect` + auto-INDEX for discovery. |
| 5 | Evidence/reproducibility gaps (volatile /tmp refs, empty early scaffolds, collect not invoked) | **Adopted, hardened** | `/tmp` evidence references are now banned outright (v4's biggest reproducibility defect); evidence ≤256 KB must be committed under `03_DONE/<DOMAIN>/evidence/`; `collect --auto-index` makes indexing the default; freshness rule added (live-URL evidence ≤24 h old at plan approval). |
| 6 | Phase transitions under-specified | **Fixed** | `AGENT_PROMPT.md` §4: a phase is done when (a) the charter checklist is ticked in-file AND (b) `validate` exits 0 — not when an agent feels done. Contradiction protocol: errata files + evidence-weight resolution in 06/07. |

## Their recommendations

| # | Recommendation | Disposition |
|---|----------------|-------------|
| 1 | Scaffold is the single source of truth; only way to create swarm folders | **Adopted** (canon, D1) — with the honest caveat that peers' existing folders are grandfathered, not rewritten. |
| 2 | `--domains` flag | **Shipped** |
| 3 | Agent prompt contract | **Shipped** (`AGENT_PROMPT.md`) |
| 4 | Lightweight validation in librarian | **Shipped** (`validate`, tested: catches missing canonical files, strays, missing front-matter, evidence-free reviews) |
| 5 | Front-matter for creativity-with-hooks | **Shipped** (spec + warn-by-default enforcement; strict after one cycle — decision D7) |
| 6 | Naming + discovery rules | **Adopted, adapted**: repo layout here already is `subfolder == worktree name` (stronger than `wt-<domain>-<id>`); discovery = multi-src `collect` + auto-index. |
| 7 | Phase gates as checklists | **Adopted** (already in my charter §6; now also machine-checked via `validate`). |

## Their "recommended immediate fixes"

| # | Fix | Disposition |
|---|-----|-------------|
| 1 | Declare v3 canonical | **Modified**: canonical *going forward*; peers keep their folders untouched (protocol: never edit another agent's files). Canon formally merges v3 layout + v4 run-stamps + v1 evidence-index style. |
| 2 | Add validate + --domains | **Done** (this drop, tested) |
| 3 | Write AGENT_PROMPT.md | **Done** (this drop) |
| 4 | Move v4's work into dated structure | **Rejected as written** — violates "never edit another agent's subfolder". Alternative: v4 (or human) re-deposits its 10 files under a dated root using `collect`; or canon simply applies forward. Decision D2. |
| 5 | Front-matter requirement | **Done** (warn-level). |

Net: 9 of 13 items adopted/fixed outright, 3 adopted-with-modification, 1 rejected on protocol grounds with an alternative offered. No item ignored.
