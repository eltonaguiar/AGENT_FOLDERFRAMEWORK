# Methodology note — measured financial-system audit (2026-11-19)

**Author:** Kilo, worktree `vanilla-handsaw`
**Applied to:** `eltonaguiar/findtorontoevents_antigravity.ca` review stored at
`eltonaguiar/antigravity_review_Nov192026`
**Purpose:** record the method that produced the findings, including what failed,
so the next swarm can repeat the parts that worked and skip the parts that did not.

This note complements `README.MD` §4 (phased protocol) and §5 (document
templates). It does not replace them.

---

## 1. What this audit was, in framework terms

| Framework phase | What it meant here |
|---|---|
| Phase 0 — Charter | `00_CHARTER.md` fixed scope to *reading* the repo and *writing* a review; source-code changes explicitly out of scope |
| Phase 1 — Isolated attempts | One worktree (`vanilla-handsaw`), one agent, targeted reads only |
| Phase 2 — Peer review | Read `02_FINDINGS/` and `05_KILO_REVIEW/` before writing; reconciled instead of duplicating |
| Phase 5 — Final verification | Re-derived every cited number from its file; three draft claims were wrong and were corrected |

The deliverable is a **report**, not a patch. When a review charter says
"out of scope: making changes to the source repo", the correct next steps are
more measurements and clearer evidence — not code edits. (A mid-session plan
that proposed editing scanner/resolver files was withdrawn for this reason.)

---

## 2. The core discipline: re-derive, don't recall

**Rule:** a number may enter the report only after it has been printed from the
file that owns it, in the same session, with the key path visible.

Why it matters: the same project carries several contradictory self-assessments
(`TRUE_PROFITABILITY_VALIDATED.md` vs the strict ledger; ghost rows 0 vs 22,947;
ETF WR 1.9% vs 43.1%). Recalled or second-hand numbers silently inherit the
wrong side of those contradictions.

Practical procedure per claim:

1. Open the JSON/CSV/MD at the exact path.
2. Print the specific key or line, not the whole file.
3. Copy the value together with its key path into the evidence index.
4. If the claim came from another agent's document, mark it "peer-sourced" and
   re-check it before adopting.

**Result this session:** three first-draft errors were caught only because of
step 2 —

| Draft | Verified |
|---|---|
| `dashboard_data.json` is "3,500 rows, 44 MB, untracked" | the file is **absent** from the worktree; 3,500 is the *live* copy's record count |
| paper ledger has 2 symbols | it has **6** |
| "price tables absent" | they **exist**; they are merely omitted from the spec |

A review that had quoted its own draft would have shipped all three.

---

## 3. Large-artifact handling

Repo is ~1.4 GB with 44 MB/2.5 MB dashboard payloads and a 27 MB DB. Rules used:

- Never `cat` a large JSON. Load it and print `list(d.keys())`, then one key at
  a time.
- For lists of unknown schema, print `{k: v.get(k) for k in candidate_keys}`
  for the first two elements to learn the field names before asserting any.
- Prefer `MAX(timestamp_column)` over row counts for freshness; counts drift
  hourly and `TABLE_ROWS` estimates lie (documented in the repo's own schema
  Appendix A.6).
- Context overflow is a real failure mode: one sibling agent died with
  `ContextWindowExceededError` (153,051 > 131,072). Budget reads accordingly.

---

## 4. Subagents: use for breadth, never for numbers

Observed in this project:

- one subagent looped and invented audit3 figures;
- one fabricated numbers outright;
- one hit the context ceiling;
- one returned "audit2 is 404" correctly.

**Rule:** subagents may enumerate, locate, and summarise structure. Any number
that will appear in the deliverable is re-derived by the author. Treat subagent
output as a lead, not as evidence.

---

## 5. Cross-agent reconciliation protocol

Before writing a new folder:

1. Read the existing findings folders (`02_FINDINGS/`, sibling review folders).
2. For each of your planned findings, record one of: **confirms**, **extends**,
   **contradicts**.
3. Put extensions in your own folder; never edit another agent's file.
4. If you contradict, show the two sources and say which you trust and why.
5. Add a "relationship to the rest of the repo" table in your `README.md`.

This session's outcome: no contradictions, several extensions (denominator
mismatch, blocklist bypass, batch artefacts, reproducibility gap, schema gaps).
That is the useful shape of a third independent pass.

---

## 6. Evidence-index format that survives review

One row per claim, columns: **claim → source file → exact location/value**.
Use key paths (`checks.ghost_rows.data.total_ghost_rows=22947`) rather than
prose, because key paths remain greppable after the file changes.

Also record:

- checkout SHA and branch for every artifact set;
- generation timestamps of each JSON (`generated_at`);
- which claims are **peer-sourced** vs self-derived;
- a "verification status" section listing errors you caught in your own draft.

That last item is the cheapest credibility signal a review can carry: it shows
the method actually ran.

---

## 7. Reusable checklist for a financial-system review

**Charter**
- [ ] Scope says read-only or lists exact permitted edits
- [ ] Out-of-scope includes "no source changes" unless explicitly granted
- [ ] Artifact store and branch named

**Data integrity**
- [ ] Ghost/duplicate rows: count, top cohorts, distinct-entry ratio
- [ ] Open vs active vs total row counts
- [ ] PnL sign and magnitude consistency, both directions
- [ ] Resolver anomalies (expired-zero, exit-beyond-stop, clamped loss)
- [ ] Freshness: `MAX(timestamp)` per table, not row counts

**Statistical honesty**
- [ ] Denominator: which population is scored, and is it the canonical one?
- [ ] Trial count vs correction method (Bonferroni/BH/DSR)
- [ ] Are the gates enabled or merely present?
- [ ] Independence: are "winners" all one source cluster?
- [ ] Survivorship: how many picks never resolve?
- [ ] Is there a forward-observation table at all?

**Surfaces**
- [ ] Do pages share a denominator?
- [ ] Do published files agree with each other (`published_disagreement`)?
- [ ] Are headline cards reproducible from committed artifacts?
- [ ] Is the kill/advisory list wired to emission, or just displayed?

**Deliverable**
- [ ] Every number has an evidence-index row
- [ ] Relationship-to-peers section exists
- [ ] Self-correction section lists draft errors
- [ ] No edits to other agents' files

---

## 8. Failure modes to name explicitly next time

1. **Recalled numbers.** Silent, plausible, wrong. Always re-derive.
2. **Scope drift into implementation.** A review that starts editing code has
   stopped being a review; withdraw and re-charter.
3. **Trusting a subagent's arithmetic.** Leads only.
4. **Comparing surfaces without checking denominators.** `/audit` and `/audit3`
   score different populations; a tile-to-tile comparison is meaningless until
   reconciled.
5. **Accepting "ok=true" as healthy.** `db_health.json` marks ghost rows
   `ok=true` while reporting 22,947 of them and `harness_healthy=false`. Read
   the values, not the boolean.
