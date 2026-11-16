# 04 — Reconciliation with `folderframework/v2/` (peer review of my work)

**Context:** after I wrote `01–03`, the `folderframework` worktree published
`folderframework/v2/PEER_REVIEW.md` (base `22a0d67`) — a cross-review of v2, v3, **and v4 (me)**.
This file reconciles the two independent cross-reviews. Net: **strong convergence; the peer added two
facts I had missed and correctly framed my remediation as unapproved.**

## Where we independently converged (high confidence)

| Finding | My `v2` | Peer `folderframework/v2` | Status |
|---|---|---|---|
| Two parallel audit dashboards; v2's "No data" is the wrong page | `01_PEER_REVIEW.md` §E | PEER_REVIEW "v2 Money-Ready: No data is the wrong page unless proven otherwise" | **Both found it** |
| Push-safety precondition (`git diff ... .github/workflows/` empty before staging) | R3 | RECOMMENDATIONS #12 | **Adopted by peer** |
| v2 L15/L30/L35 are real, L103 partly stale | §B | "v2 display bug is real" / "v2 bug 3 is already partly fixed" | **Agree** |
| v3 final_review4 is blank templates | §C | "v3 Phase-5 files are not a plan" | **Agree** |
| Non-destructive; no ghost-row deletion; prediction shadow (PBO 0.603) | R5/R8 | RECOMMENDATIONS #8–10 | **Agree** |
| Use v3's `swarm_librarian.py` as the one tool | R-6 | RECOMMENDATIONS §"If one tool is kept" | **Agree** |

## Where the peer added to my analysis (accept)

1. **`enhanced_audit_dashboard.py:106-109` hardcodes `win_rate: 55.0` and `sharpe: 0.3`.** I flagged the `55.0` hardcode but not `sharpe: 0.3` nor the exact line range. Verified in tree: L106 `'win_rate': 55.0`, L109 `'sharpe': 0.3`. **Adopted** — this is a larger display lie than the stale L103 None-coalesce.
2. **"v4 remediation is not approved work."** Correct framing. My cron stagger / `db_freshness.json` deletion / sports rename are **proposals**. My `02_*` already marks them plan-only; I restate here: **none of my Phase B/C is adopted until D3 is answered.**

## Where I refine the peer (evidence-based, not a veto)

1. **`audit_systems.py:35` — peer says "leave alone until D1; zero-as-loss is a defined choice, not a proven bug."** I verified L35 `wins = sum(... > 0)` and L36 `losses = sum(... <= 0)`, so a zero-PnL trade is counted a loss. That is a **real correctness bug** independent of D1 (break-even is not a loss). I agree the *priority* depends on D1 (the script runs in no workflow), but disagree it is merely "a defined choice." Recommend: fix when touched, but do not prioritize over the live `/audit` surface.
2. **Dashboard surface naming.** Peer calls `audit_dashboard/` "the production audit page served at findtorontoevents.ca/audit." My `site_impact_audit.md` confirms the FTP `/audit` writers (`audit-dashboard.yml` primary). So "production = `audit_dashboard/`" is **corroborated** — D1's answer is effectively (a), pending the one open check (is committed `dashboard/index.html` served anywhere?).

## Net effect on my `02_FINAL_RECOMMENDATIONS.md`

- R2 (decide dashboard first) is now **corroborated by an independent reviewer** → raise confidence.
- R3 (push-safety first) is **adopted by the peer** → keep.
- R5 (AUDIT claim hygiene, display-only) — peer agrees; keep.
- R6/R7 (my Phase B/C) — **reaffirm as plan-only**, per peer's correct framing.
- D1 — narrow to "is `dashboard/index.html` served publicly?" (the only remaining unknown); everything else points to `audit_dashboard/`.
- Add to R-7 research: **the `sharpe: 0.3` / `win_rate: 55.0` hardcode** is a shared display-integrity item across both reviews.

## Status

My `v2/` and the peer's `v2/` are now **mutually consistent**. Neither overwrote the other (separate subfolders). If a third reviewer lands, the merge rule from the framework applies: evidence weight + risk, not voting.