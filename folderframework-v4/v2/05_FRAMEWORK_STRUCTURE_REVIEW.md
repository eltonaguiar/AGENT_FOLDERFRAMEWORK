# 05 — Framework structure review (incorporating the external meta-review)

**Source:** external review of `eltonaguiar/AGENT_FOLDERFRAMEWORK` (forwarded 2026-11-16), which
confirms the framework is sound but flags six structural gaps and a consistency problem — and
explicitly names **v4 (mine)** as the layout deviant ("abandons the dated SWARM root").

**Stance:** I agree with the core diagnosis. This file assesses each issue with evidence, states where
I refine it, and converts it into new recommendations (R9–R12) and decisions (D8–D11) that are also
folded into `02_FINAL_RECOMMENDATIONS.md` / `03_OPEN_QUESTIONS_AND_RESEARCH.md`.

---

## 1. Issue-by-issue assessment

### 1.1 Inconsistent structure across versions — **AGREE (and I am the deviant)**
Verified trees:
- `folderframework-v2/2026-11-16-SWARM/00_CHARTER/00_CHARTER.md` — charter as a **folder**.
- `folderframework-v3/2026-11-16-SWARM/{00_CHARTER.md, 01_TODO/, 03_DONE/, 04..07 phases}` — **canonical dated SWARM**.
- `folderframework-v4/{00_CHARTER.md, 03_DONE/, 07_final_review4/, v2/}` — **no dated root** (mine).

Refinement: a single-domain worktree *feels* like it doesn't need the 4-domain scaffold, but that is
exactly how drift starts. **Fix:** one canonical layout (v3's), enforced by the librarian + a validator.
I accept that my folder should migrate (see §3 mapping, D8).

### 1.2 Hard-coded domains, not generic — **AGREE**
`DB/GHACTIONS/AUDIT/PREDICTION/CROSSCUTTING` are baked into the scaffold and READMEs. The framework is
sold as reusable but a new domain (`FRONTEND`, `SECURITY`, `ML_CALIBRATION`) requires forking structure.
Refinement: my own GHACTIONS folder *proves* domains are extensible in practice (I picked one freely),
but there is no **supported** way to declare one. **Fix:** `--domains` flag + `swarm_config.yaml`; make
`CROSSCUTTING` a first-class escape hatch with its own schema, not an afterthought.

### 1.3 No enforcement of placement — **AGREE**
`swarm_librarian.py` can `collect`/`index` but nothing *rejects* a misplaced file or a missing required
template. **Fix:** add a `validate` subcommand (required phase folders; every `03_DONE/` file has an
evidence link; `07_final_review4/` has the 5 canonical files; flag files outside the allowed tree). Wire
it as a pre-commit/CI step. This is the single highest-leverage fix after the agent prompt.

### 1.4 Missing operational pieces — **AGREE (agent prompt is #1)**
No mandatory agent preamble; no machine-readable contract; no new-SWARM-vs-append rule; worktree naming
and librarian discovery undefined; CROSSCUTTING under-specified. **Fix:** an `AGENT_PROMPT.md` contract
(path, filename pattern, required sections, "do not create top-level folders") + a small YAML front-matter
block. Everything after the front-matter stays free-form — strict on placement, loose on content.

### 1.5 Evidence & reproducibility — **PARTLY AGREE**
v4 is strong on evidence by design (path + SHA + command per claim, plus a sidecar `branch_capability.tsv`
so raw evidence doesn't pollute prose — a reusable pattern). But: the librarian `collect` is manual, and
earlier versions are mostly empty scaffolds. **Fix:** front-matter `evidence:` list that `validate` checks
actually resolves; make `collect` part of the librarian's documented flow and invoke it in the phase gate.

### 1.6 Phase-transition rules under-specified — **AGREE**
No definition of "Phase 1 done," who advances `03_DONE → 04_final_review`, no stall/timeout beyond the
original suggestion, no tie-break when two `final_review` files contradict. **Fix:** phase gates as a
checklist in `00_CHARTER.md` (v3 has a good one) that the synthesizer must tick; add a stall detector
(no commit in N hours → librarian archives) and "evidence weight + risk" as the standing conflict rule.

---

## 2. The external review's 7 "consistency" moves — my disposition

| # | Move | My take | Priority |
|---|---|---|---|
| 1 | v3 dated-SWARM = the only allowed structure; librarian `scaffold` is the only door | **Adopt** | P0 |
| 2 | `AGENT_PROMPT.md` contract (path, filename, sections) | **Adopt — highest leverage** | P0 |
| 3 | `validate` subcommand + pre-commit | **Adopt** | P0 |
| 4 | YAML front-matter (agent/domain/phase/status/evidence) | **Adopt**, keep it tiny | P1 |
| 5 | Naming/discovery (`wt-<domain>-<id>`; `collect` takes globs; always write `INDEX.md`) | **Adopt** | P1 |
| 6 | Phase gates as checklists, not bureaucracy | **Adopt** (v3's checklist) | P1 |
| 7 | Generic domains via `swarm_config.yaml` / `--domains` | **Adopt** | P1 |

No disagreements with the seven. My only addition: #3 and #2 together fix issues 1.1/1.3/1.4 — do them
first, before #4–#7, because enforcement + contract prevent drift while the softer conventions are written.

---

## 3. The 5 "immediate fixes" — disposition, and what I will do

| # | Fix | Disposition |
|---|---|---|
| 1 | Declare v3 + `swarm_librarian.py` canonical | **Endorse** (R9) |
| 2 | Add `validate` + `--domains` to librarian | **Endorse** (R10) — I can draft the `validate` checks |
| 3 | One-page `AGENT_PROMPT.md` | **Endorse** (R11) — I can draft it |
| 4 | **Move v4 GHACTIONS work into a dated SWARM structure** | **Endorse; hold execution on D8** — see mapping below |
| 5 | Simple front-matter requirement | **Endorse** (R12) |

### v4 migration mapping (executable once D8 is approved)
```
folderframework-v4/2026-11-16-SWARM/
├── 00_CHARTER.md                 ← from folderframework-v4/00_CHARTER.md
├── 03_DONE/GHACTIONS/…           ← from folderframework-v4/03_DONE/GHACTIONS/…
├── 04_final_review/…             ← (empty placeholder; my 01_PEER_REVIEW content is cross-review)
├── 05_final_reviewv2/…           ← from folderframework-v4/v2/  (the "v2" the user asked for)
└── 07_final_review4/…            ← from folderframework-v4/07_final_review4/…
```
Why hold: a peer (`folderframework/v2/PEER_REVIEW.md`) already cites `folderframework-v4/07_final_review4/`
by path. Moving published paths is a coordination decision (the framework's own human-gate principle), so
I flag it as D8 rather than unilaterally rewriting paths another agent referenced. I will leave a top-level
`README.md` that maps old→new so nothing is orphaned.

---

## 4. What this adds to my earlier v2 conclusions

- **R2 (decide the dashboard) is unaffected** — this is orthogonal; still the top domain question (D1).
- **New structural track (R9–R12 / D8–D11) sits *above* the domain work**: get the container right first,
  then per-domain content (my GHACTIONS, peers' AUDIT) lands consistently without re-litigating layout.
- **The two-dashboard finding and push-safety precondition are unchanged** and now have an independent
  corroboration (see `04_PEER_RECONCILIATION.md`).
- **Honest self-note:** my v4 is the clearest example of the inconsistency the review flags. The fix is not
  to defend the flat layout but to migrate — which is why I gate it on D8 instead of leaving it as prose.