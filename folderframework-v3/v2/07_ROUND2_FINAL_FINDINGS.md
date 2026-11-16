# 07 — Round-2 final findings (folderframework-v3)

**Base:** `AGENT_FOLDERFRAMEWORK/main @ 55f88cf` (all four round-2 drops landed).
**Source-repo checks:** `eltonaguiar/findtorontoevents_antigravity.ca`, worktree `db4cc06ed82`, `origin/main` observed at `c284ba25fe4`.
**Live checks:** `findtorontoevents.ca/audit/` endpoints curl'd 2026-11-16T06:19Z.

This is the closing document of round 2: per-peer verdicts, adjudication of every cross-peer disagreement, new facts established this round, the full consensus matrix, and the merged "what still needs work" list.

---

## 1. Round-2 verdicts per peer

### `folderframework` (v1) — `v2/` overlay (9 files)
Shipped the strongest *review methodology* layer: `PEER_REVIEW` (verified every peer claim line-by-line against the tree), `LAYOUT_CONTRACT`, `AGENT_PROMPT`, `PHASE_GATES`, decision list D1–D14.
- New finding it contributed, **verified by me in seconds**: `enhanced_audit_dashboard.py:106-109` hardcodes `'win_rate': 55.0` and `'sharpe': 0.3` (comments "From audit report" / "Estimated low") — a display lie that v2 missed entirely and v4 caught only half of (55.0, not sharpe).
- New caveat it contributed: `live_tracker.yml` may overwrite `dashboard/index.html` from `alpha_engine/live_dashboard.html` — meaning even the secondary dashboard's writer is uncertain.
- Its layout contract is 95% identical to my canon; the two deltas (`evidence/` placement, new-dated-folder trigger rule) were **adopted by me** — my librarian, `AGENT_PROMPT.md`, and front-matter spec now match its wording (evidence dirs live at top level; new root when charter date/scope/domain-set changes).

### `folderframework-v2` (v2) — full restructure + deepened bug list
Obeyed canon in round 2 (charter-folder flattened, dated nest, full review4 set, VALIDATE_SPEC with 9 checks incl. secret/scan ideas beyond my current linter). Its PLAN now carries 9 root causes. My line-level verification of its *new* round-2 claims:

| Claim | My verification | Verdict |
|---|---|---|
| RC2: 22/24 live picks render "negative" via `> 0` at `generate_dashboard.py:15` | `live_picks.json`: exactly **22 of 24** picks have `unrealized_pnl_pct == 0` | confirmed — the secondary dashboard currently paints 92% of its table red |
| RC4: side vocabulary — `BUY`/`SELL` render as SHORT badge (L14 tests `== "LONG"`) | sides observed: **{BUY:6, LONG:4, SHORT:11, SELL:3}** → 9/24 picks mis-badged | confirmed — new real bug, caught only by v2 |
| RC6: None-unsafe aggregation moved to `enhanced_audit_dashboard.py:26` (`p.get('pnl_pct', 0)`) | line 26 exact; explicit `None` bypasses the default, crashes `sum` | confirmed (repositioned correctly from the stale L103) |
| RC7: audit tools read different Battleground populations (5.3% vs 56.9% WR) | both sources exist (`ml_battleground/system_*/` ×6 files vs `battleground/data/closed_picks.json` = 123 picks) | structurally confirmed; WR arithmetic not re-run |
| Bug list staleness | its `03_DONE` report **still carries the stale L103 text** while its own PLAN's RC6 moved on — internal inconsistency | flag: report needs a one-line errata |

### `folderframework-v4` (v4) — `v2/` overlay (6 files)
Shipped the reconciliation layer: `01_PEER_REVIEW` (two-dashboard split table), `04_PEER_RECONCILIATION` (mutual-consistency proof with v1), `05_FRAMEWORK_STRUCTURE_REVIEW` (accepts itself as the layout deviant; executable migration mapping, held on D8). Its round-2 added one unique insight none of us had: **prediction-market steps in `audit-dashboard.yml` run with `|| echo "… (non-fatal)"` (lines 117–121)** — PM failures are swallowed by design, a GHACTIONS×PREDICTION blind spot (R-7 in its research list).

### Me (v3) — this folder
Librarian v2.1 (scaffold `--domains` + `validate` + multi-src `collect` + `evidence/` dirs, all tested), `AGENT_PROMPT.md`, front-matter spec, and the two review passes. Peers' flag that my Phase-5 files are blank templates is **correct and by design** — disambiguation note added to `2026-11-16-SWARM/README.md`.

---

## 2. Adjudications — cross-peer disagreements resolved by evidence weight + risk

| # | Disagreement | Positions | Ruling |
|---|---|---|---|
| A1 | Zero-PnL in `audit_systems.py:35`: definition choice or real bug? | v1: definition, leave alone (D1). v4: real correctness bug. v2 round-2: Step 6 counts break-even as its own reported bucket, not a win or loss | **Adopt v2's design** (neutral bucket, WR math unchanged) — it dissolves the disagreement: v1's "don't churn WR math" and v4's "break-even isn't a loss" are both honored. Display class = neutral; win/loss counts exclude break-even |
| A2 | `evidence/` placement | v1: top-level `evidence/<DOMAIN>/`. me (round-1): `03_DONE/<DOMAIN>/evidence/` | **v1 wins** — evidence serves all phases, not just Phase 1. Librarian + contracts updated this round |
| A3 | New dated-SWARM trigger | v1: charter date/scope/domain-set change. me: mission-day | **v1 wins** — crisper, testable |
| A4 | v4 folder migration | external review + v2: move into dated nest. v4: executable mapping, held on D8 (peers cite its paths). v1: copy-not-move, wait for human (D11). me (round-1): leave flat | **Consolidated: human decision, default = v1's copy-with-source-SHA via librarian when requested.** No agent moves paths unilaterally |
| A5 | "Money-Ready shows No data" | v1/v4/me: empty verdict ≠ missing-data tile. v2 (round-1): panel broken. v2 (round-2): self-corrected in its retractions | **Converged:** live verdict is `[]` (05:53Z fetch); render explicit "0 classes ready (n=10 scanned)", never a fabricated class. v1's S3-wording caution adopted |
| A6 | Is `dashboard/` a production surface? | v4 D1, v1 D3/D14, all open | **Still open — the single highest-leverage human question** (Q-list). Everything else about v2's bug-fix priority depends on it |

## 3. New facts established this round (by this review pass)

1. **The ghost-row "0 vs 22,947" mechanism is fully traced**: `audit_dashboard/dashboard_enhancements.js` renders the live count correctly (L754, `_ghostLive` at L822) — the "0" is a **stale hardcoded remediation sentence at L829-833** ("2026-05-31: 0 ghost rows confirmed … all cleared as of 2026-05-31 DB audit") inside the same red banner that prints the live 22,947 beside it. Fix class: delete/replace the hardcoded note with the live remediation status. Neither v1 nor v2 located this line; both hypothesized boolean-vs-count confusion in the display layer — actually the display layer reads counts correctly and the lie is a frozen string.
2. **Two of v4's nine proposals are already landed on `origin/main`** by an outside the swarm commit (`20f6e1cdad1`, cites the GHACTIONS audit): the `/audit` deploy concurrency group (its Step 9) on both `deploy-competition-to-site.yml` and `deploy-fte-index.yml`; `db-freshness-check.yml` no longer exists (its Step 7-A1 moot). Its Step 7-B2 (delete committed stale `db_freshness.json`) remains open and verified still-needed.
3. **Live endpoint state (06:19Z)**: `money_ready_verdict.json` → `money_ready=[]`, `watch=[COMMODITY]` (05:53Z); `dashboard_data.json` parses with strict stdlib `json` (no Infinity/NaN tokens live today); `/audit/` returns 200 (1.43 MB). v1's locally-derived claims hold against production.
4. **Duplicate `_snapshot_prediction_market_entry`**: both copies are *live* (resolver copy called at `universal_pick_resolver.py:1423`; generator copy at `/dashboard_generator.py:1764`) — dedup direction is a real decision, not dead-code cleanup.

## 4. Consensus matrix (what all four agents + external review now agree on)

- Canon = dated `YYYY-MM-DD-SWARM/` root; v3 librarian is the single tool; `AGENT_PROMPT.md` + YAML front-matter mandatory; `validate` gates phase transitions; contradict via new files, never edits.
- Display claims must quote `checks.*.data` counts (+ tier, + n), never `ok` booleans; Money-Ready renders the empty verdict explicitly; no ghost/open row deletion in any display pass; prediction markets stay shadow (PBO 0.603); no workflow remediation without the push-safety precondition (`fetch` + empty `git diff --name-status HEAD origin/main -- .github/workflows/`).
- Round-1 plans are plans, not approvals; the human merges.

## 5. What still needs work (merged, tiered)

**(i) Quick display/correctness fixes — ready now, all verified:**
1. Replace the frozen 2026-05-31 remediation string in `dashboard_enhancements.js:829-833` with live-driven text (the "0 ghosts" lie). *Found here.*
2. Money-Ready empty state: "0 classes money-ready (n=10 scanned)" + per-class `n` verdict table; COMMODITY stays WATCH.
3. `generate_dashboard.py`: neutral class for break-even (22/24 picks affected) + `normalize_side()` for BUY/SELL (9/24 mis-badged). *v2's round-2, my verification.*
4. `enhanced_audit_dashboard.py:106-109`: remove/label hardcoded `win_rate 55.0` / `sharpe 0.3`. *v1's finding; do NOT "re-fix" L103.*
5. `audit_systems.py:35`: neutral-bucket design per A1 ruling.

**(ii) Plumbing fixes — decision-gated:**
6. v4 Step 7-B2: delete committed `db_freshness.json` + sweep 3 doc references (D3).
7. Cron-stagger pilot on `0 */2` tier only, after re-pinning counts at a fresh SHA (D6); concurrency backfill in ~20-file batches, dual-mode first.
8. Fold v2's VALIDATE_SPEC extras (V4 evidence-resolution, V8 conflict-marker scan, V9 secret patterns) into `swarm_librarian.py validate` — next librarian pass.
9. Errata: v2's `03_DONE` report still carries the stale L103 text; v4 owes the 16-inconsistency reconciliation + committed evidence (its `/tmp` artifacts are gone or uncommitted).

**(iii) Research/strategy — separate track:**
10. Dashboard-authority question (A6/D1): is committed `dashboard/index.html` served anywhere, and does the `live_dashboard.html` overwrite path fire on the runner?
11. Fresh `audit-dashboard.yml` run-log pull (~15 runs): is 404-JS/Infinity historical or live? (v1's open item; v4 R-2).
12. PM silent-failure audit: are the `|| non-fatal` PM steps in `audit-dashboard.yml:117-121` succeeding or no-op'ing? (v4 R-7).
13. Sports workflows: one GitHub-API pass on `disabled_manually` flags before any banner/rename decision (D4).
14. `_snapshot_prediction_market_entry` owner decision + contract-price unit test before any dedup (Q1/R16).

## 6. Unified open-decision list (across all agents, current status)

| Decision | Status after round 2 |
|---|---|
| Canon ratification (layout, librarian, prompt, front-matter) | **Ready for human yes** — all four agents converged + external review endorsed |
| Dashboard authority (`audit_dashboard/` vs `dashboard/` vs manual legacy) | **Open — blocks v2's fix prioritization** |
| `db_freshness.json` deletion + doc sweep | Open; evidence complete, zero consumers verified by v4 |
| v4 folder migration | Open; default = librarian copy-with-SHA when asked |
| Sports retire/banner/rename | Open; needs one API pass (F1/F13) |
| Branch pruning | Open; Tier 0 (7 merged branches) safe, bulk tiers deferred |
| Zero-PnL display class | **Resolved by A1 ruling (neutral) unless human overrules** |
| Cron stagger | Open; pilot-first recommendation pending |
| Front-matter strictness | Open; warn now, `--strict` + CI gate after one full cycle (F7) |

---
*Round-2 state: four agents, zero unresolved contradictions left standing except the ones requiring the human's answer above.*
