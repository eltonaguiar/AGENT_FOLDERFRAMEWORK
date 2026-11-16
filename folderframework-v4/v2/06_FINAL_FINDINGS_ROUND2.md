# 06 — Final findings (Round 2 capstone)

**Author:** `folderframework-v4` · **Date:** 2026-11-16 · **Artifact base:** `eltonaguiar/AGENT_FOLDERFRAMEWORK` @ `55f88cf`
**Scope:** capstone over the completed round-2 work of `folderframework`, `folderframework-v2`, and `folderframework-v4` (me). `folderframework-v3` was still in progress at review time — see §7.

> This file is the "final findings, for now." It supersedes nothing; it indexes `01–05` and states where the swarm landed after round 2.

---

## 1. Round-2 status per agent

| Agent | Round-2 artifact | State | One-line verdict |
|---|---|---|---|
| `folderframework` | `folderframework/v2/` (PEER_REVIEW, LAYOUT_CONTRACT, AGENT_PROMPT, PHASE_GATES, RECOMMENDATIONS, DECISIONS D1–D14, OPEN_QUESTIONS, FURTHER_RESEARCH) | **complete** | Full pilot + structural contract; strongest decision register. |
| `folderframework-v2` | `2026-11-16-SWARM/` canonicalized + `05_final_reviewv2/` + filled `07_final_review4/` + `templates/{AGENT_PROMPT,VALIDATE_SPEC,swarm_config}` | **complete** | Canonicalized its layout and produced a real AUDIT plan with 9 root causes. |
| `folderframework-v4` | `folderframework-v4/` + `folderframework-v4/v2/` (this) | **complete** | GH Actions record; highest evidence-linking. |
| `folderframework-v3` | `folderframework-v3/v2/` (01–03) + `swarm_librarian.py` **v2.1** (`validate`/`--domains`) + `AGENT_PROMPT.md` + front-matter spec | **complete** (landed `a9deb2c`, 06:31Z) | Implemented the structural track; verified peers; found 2 of my GH steps already landed. |

---

## 2. Convergence scorecard (what the swarm now agrees on)

The most important result of round 2 is that **all three completed agents independently converged** on the same conclusions. That convergence is itself evidence (not a vote):

| Converged position | folderframework | v2 | v4 (me) |
|---|---|---|---|
| v3 dated-SWARM = canonical layout; v2-char/ folder + v4 flat root are drift | ✅ D10/D11 | ✅ §3.1 | ✅ D8 |
| Adopt `swarm_librarian.py`; add `--domains` + `validate` | ✅ D8 | ✅ §3.2 | ✅ D9/R10 |
| Mandatory `AGENT_PROMPT.md` contract | ✅ AGENT_PROMPT.md | ✅ §3.2 | ✅ R11 |
| YAML front-matter (`agent,domain,phase,status,evidence`) | ✅ LAYOUT_CONTRACT | ✅ §3.4 | ✅ R12 |
| Evidence in `evidence/<DOMAIN>/`, link from markdown | ✅ | ✅ | ✅ R-11 |
| Two audit dashboards; "No data" ≠ empty verdict | ✅ | ✅ | ✅ `01` §E |
| Non-destructive (no row deletes, no combo fabrication) | ✅ D5 | ✅ | ✅ R5 |
| Prediction markets shadow (PBO 0.603) | ✅ | ✅ | ✅ R8 |
| v4 GH Actions is the reference artifact | ✅ | ✅ | (self) |
| Push-safety precondition before any workflow edit | ✅ D6/agent-prompt | ✅ | ✅ R3 |

**No material disagreements remain** between the completed agents. The earlier apparent contradiction (Money-Ready "empty" vs "No data") is resolved: different dashboards (live `/audit` = `audit_trail/dashboard_generator.py`; repo `dashboard/index.html` = `live_tracker.yml`).

---

## 3. Consolidated domain findings (merged)

### 3.1 AUDIT (from `folderframework` + `v2`, merged)
- **Claim hygiene:** boolean gates (`checks.*.ok`, `banner_should_show`) are not counts. `db_health.json` @ `db4cc06ed82`: `ghost_rows.ok=true` but `total_ghost_rows=22947`; `trading_picks.open_count=91705` vs `active_count=21`; `bt_backtest_trades.open_count=29247197` is a *third* number, not the same population. Always quote `data.*`.
- **Money-Ready:** `money_ready_verdict.json` @ `2026-11-16T01:44:34Z` → `summary.money_ready=[]`; COMMODITY is WATCH (wr 0.4017, pf 1.0256), not ready. "No data" tile is a missing-JSON fallback, not an empty-verdict state.
- **Code bugs (verified by me + v2):**
  - `dashboard/generate_dashboard.py:15,30` — `> 0` paints break-even red. **real.**
  - `dashboard/generate_dashboard.py:14` — `side == "LONG"` vs data `{BUY,LONG,SELL,SHORT}` → BUY/SELL mis-badged (**v2 RC4**, new, real).
  - `audit_systems.py:35-36` — zero-PnL counted as loss. **real.**
  - `enhanced_audit_dashboard.py:106-109` — hardcoded `win_rate: 55.0` / `sharpe: 0.3` (worse than the already-fixed L103 None-coalesce).
  - **v2 RC7 (new, strong):** data-source drift — `audit_systems.py` reads `ml_battleground/.../closed_picks.json` (WR 5.3%) while `enhanced_audit_dashboard.py` reads `battleground/data/closed_picks.json` (WR 56.9%). Two tools, contradictory headlines.
  - `hub/data/integrated_dashboard.json` stale (`last_update 2026-03-02`, `active_systems=0`); `hub/data/winning_combos.json` `total_found=0`.

### 3.2 GHACTIONS (mine, unchanged)
- No push hazard on main (0/358); earlier "4 hazards" and "235 stale" retracted.
- Stale-fork trap: 88367 ahead / 15 behind; 12-row workflow delta; never `git add .github/workflows/`.
- `dynamic-alpha-engine.yml` must stay `timeout-minutes: 90`.
- Cron minute-0 pile-up (52.5%) + concurrency gaps (192/356 uncovered) — reversible, deferred.
- `/audit` delta impact = none; residual risk = `deploy-competition-to-site.yml` unguarded.
- Untracked `.github/workflows/lint.yml` must not be committed.

---

## 4. Consolidated decision register (merged, deduped)

`folderframework` filed D1–D14; I filed D1–D11; v2 filed 7. Merged and deduped below. **BLOCKING** = answer before writing code.

| ID | Decision | Options | My weight / recommendation | Blocking? |
|---|---|---|---|---|
| **B1** | Exact-zero PnL class | neutral / win (`>=0`) / loss | **neutral** for display; do not change WR math in same commit (folderframework D1) | yes (display) |
| **B2** | Which dashboard is authoritative | live `/audit` (`audit_trail`) / repo `dashboard/` (`live_tracker`) / legacy scripts | **`audit_trail` for the public site**; but folderframework **D14** notes `live_tracker.yml:43-44` overwrites `dashboard/index.html` from `alpha_engine/live_dashboard.html` — so v2's `dashboard/` bugs may be moot. **Verify first.** | **YES — top blocker** |
| **B3** | Money-Ready "has data" meaning | render verdict incl. empty (A) / ≥1 ready (B) | **A** (B violates the sizing gate) | yes (copy) |
| **B4** | Normalize v4 into dated-SWARM | copy now (librarian, keep SHA) / leave flat | **copy, not move; hold on human** (folderframework D11 + my D8) | no (coordination) |
| S1 | Canonical librarian | v3 CLI / init-only | **v3 CLI** + add `validate`/`--domains` | no |
| S2 | Front-matter scope | new files only / retrofit all | **new files only** | no |
| S3 | Phase closure owner | synthesizer checklist / any agent | **synthesizer, human at Phase 5** | no |
| S4 | Canonical layout | v3 dated-SWARM / per-worktree | **v3 dated-SWARM** | no |
| D-def | Apply v4 Phase B (cron/concurrency) now | later file-by-file / now | **later** | no |
| D-fr | Delete `db_freshness.json` + archive legacy | yes / re-check consumers | **re-check first** | no |
| D-sn | Dedup `_snapshot_prediction_market_entry` | after caller trace / edit both | **after trace** (resolver:934 vs dashboard_generator:5493) | no |
| D-sp | Sports retire banner + rename | retire / leave | decision-gated, dated banner | no |
| D-pm | Prediction markets | shadow / promote | **shadow** | no |

---

## 5. Open questions (top, carried)

1. **B2** — is committed `dashboard/index.html` even served, or does `live_tracker.yml` overwrite it? (folderframework D14). This decides whether v2's AUDIT code fixes matter to the public site.
2. Which `_snapshot_prediction_market_entry` copy runs live? (`audit_trail/universal_pick_resolver.py:934` vs `audit_trail/dashboard_generator.py:5493`).
3. Is the 404-JS / Infinity emission still live? (needs a **fresh** `audit-dashboard.yml` run log; not re-run this round).
4. Who produces `hub/data/*.json`? (no workflow references it in `audit-dashboard.yml`).
5. Are the 5 sports workflows actually disabled? (GitHub-side flag, unverifiable in git).

---

## 6. Further research / discussion

- **R-8 (do first):** build `swarm_librarian.py validate` (V1–V9 from `folderframework-v2/.../VALIDATE_SPEC.md`) and run it against all four folders → publish the violation baseline. V1+V5 alone would have caught v2's charter-folder and v4's flat root.
- **R-9:** dry-run `AGENT_PROMPT.md` + `--domains FRONTEND` on a throwaway domain to prove genericity.
- **R-10:** fresh `gh run` log pull for `audit-dashboard.yml` to close Q3 (converts "still open?" into a dated verdict).
- **R-11:** import/caller trace for the duplicate snapshot function (closes Q2).
- **R-12:** evidence subfolder standard (`evidence/<DOMAIN>/`) + front-matter `evidence:` that `validate` checks resolves.

---

## 7. `folderframework-v3` status (in progress) + next check

At this review, `folderframework-v3` has:
- Cleanest scaffold (`2026-11-16-SWARM/` with all phases + templates) and a working `tools/swarm/swarm_librarian.py`.
- `07_final_review4/*` are **unfilled templates** (PLAN/EVIDENCE/FILES/STEPS/TESTING).
- **No round-2 (v2) folder and no domain findings yet** in either its local worktree or the artifact repo.

Per the plan, I re-check v3 after finishing the completed agents. If v3 has since landed a `05_final_reviewv2/` or filled `07_final_review4/`, the capstone above should be amended to fold in v3's content and (if it built `validate`/`--domains`) to credit v3 as the implementer of S1/R-8.

**Re-check result (2026-11-16, ~06:22Z):** v3 had **not advanced** at that moment (worktree clean at `db4cc06ed82`; artifact repo still at `22a0d67`). **Update (~06:31Z):** v3 **then landed** `a9deb2c` — full round-2 (`v2/01–03`), `swarm_librarian.py` **v2.1** with `validate` + `--domains`, `AGENT_PROMPT.md`, and front-matter spec. All four agents are now complete. v3's new facts folded into `07_ACTION_PLAN_NEXT_STEPS.md` and the verdict in `08_FINAL_VERDICT.md`.

---

## 8. My round-2 recommendation (short)

1. **Answer B2 first** (which dashboard is live) — it gates all AUDIT code work.
2. **Execute the converged structural track** (S1–S4, R-8, R-9): declare v3 canonical, build `validate` + `--domains`, ship `AGENT_PROMPT.md`. This is the highest-leverage, lowest-risk work and all three agents agree.
3. **Then** do the display-only AUDIT fixes (B1 neutral badge, B3 empty verdict) and my GH Actions guardrail (push-safety precondition).
4. **Defer** everything touching rows, combos, prediction feeds, cron sweeps, sports, and `db_freshness.json` until its decision is explicit.