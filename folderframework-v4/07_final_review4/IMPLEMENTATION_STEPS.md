# IMPLEMENTATION_STEPS — GH Actions remediation

Each step is independently revertible. "Rollback" is the exact reverse. Nothing here has been applied;
these are proposed, ordered steps. All repo paths are relative to
`eltonaguiar/findtorontoevents_antigravity.ca`.

> Global precondition for any step that touches `.github/workflows/`:
> ```bash
> git fetch origin main
> git diff --name-status HEAD origin/main -- .github/workflows/   # must be 0 rows before you start
> ```

---

## Step 1 — Publish the audit record (this folder)
- **File(s):** `AGENT_FOLDERFRAMEWORK/folderframework-v4/**`
- **Change:** deposit the 10 source deliverables + this `07_final_review4/` package.
- **Risk:** none (separate repo).
- **Rollback:** `git revert <sha>` on `AGENT_FOLDERFRAMEWORK`.

## Step 2 — Freeze the push-safety guardrail (process)
- **File(s):** `AGENTS.md` (contributor rules); optionally a `.github/scripts/assert_no_conflict_markers.sh`-style guard.
- **Change:** add the rule "never `git add .github/workflows/` wholesale; build patches against `origin/main`'s blob; stage `GHACTIONS_*/**` docs file-by-file." Adopt the `push_unbranched_nopaths` (two-axis) vocabulary.
- **Risk:** none.
- **Rollback:** revert the `AGENTS.md` hunk.

## Step 3 — Restore/confirm the 90-minute timeout (only if a push put `60` back)
- **File:** `.github/workflows/dynamic-alpha-engine.yml`
- **Change (exact):**
  ```bash
  git checkout origin/main -- .github/workflows/dynamic-alpha-engine.yml
  grep -n "timeout-minutes: 90" .github/workflows/dynamic-alpha-engine.yml   # expect line 115
  ```
- **Risk:** high if skipped (reintroduces cancel-churn). This step *removes* that risk.
- **Rollback:** not applicable — main is the source of truth; re-running is idempotent.

## Step 4 — Cron stagger, worst tiers first
- **Files:** the 5 collision groups in `03_DONE/.../cron_stagger_plan.md` (15+13+13+12+10 files).
- **Change:** apply the deterministic offset `zlib.crc32(filename) % 60` per file, alphabetical `+1 mod 60` tie-break within each group (e.g. `signal_tracking.yml` 34→35, `sign-coherence-gate.yml` 32→33). **Stagger only — do not delete cron entries** in the 17 `github.event.schedule` dispatch files.
- **Risk:** medium (behavioral). Semantics unchanged; only the minute within each window moves.
- **Rollback:** revert the per-file cron line to the original string.

## Step 5 — Concurrency coverage on dual-mode / uncovered files
- **Files:** 192 files without `concurrency:` (see `cron_stagger_plan.md`), dual-mode first.
- **Change:** add
  ```yaml
  concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: false
  ```
  `false` deliberately — never cancel an FTP upload mid-transfer.
- **Risk:** medium. `cancel-in-progress: false` can queue runs; verify no self-deadlock on the 26 dual-mode files.
- **Rollback:** remove the added `concurrency:` block.

## Step 6 — Add a stagger linter (prevent drift)
- **File:** new `.github/workflows/` lint or pre-commit hook.
- **Change:** implement the stagger spec (`cron_stagger_plan.md` §"Stagger policy specification") as a check that fails on minute-0 collisions above a threshold.
- **Risk:** low.
- **Rollback:** disable the lint.

## Step 7 — DB-freshness: archive legacy + guardian as source of truth (independent A1 + B2)
- **Files:** `.github/workflows/db-freshness-check.yml` (rename to `.yml.disabled`); delete committed `audit_dashboard/data/db_freshness.json` from the tree; keep `db-freshness-guardian.yml` artifact as the source of truth.
- **Change:** A1 archive the manual committer; B2 stop relying on the committed JSON. Also update `AGENTS.md`, `HEARTBEAT.md`, `docs/MYSQL_ENV_SETUP.md` references that tell a human to dispatch `db-freshness-check`.
- **Risk:** low. Blast radius is zero today (no PHP/JS/HTML consumer reads `db_freshness.json` — verified by `git grep`).
- **Rollback:** `git mv db-freshness-check.yml.disabled db-freshness-check.yml`; `git checkout <sha> -- audit_dashboard/data/db_freshness.json`.

## Step 8 — Sports: retire with an explicit banner (decision-gated C1)
- **Files:** `/live-monitor/sports-betting.html` (banner); rename the 5 `sports-*.yml` to `.yml.disabled` to record intent.
- **Change:** add a date-stamped "Sports monitoring retired as of <date>; figures below are historical" banner; commit the `.yml.disabled` rename.
- **Risk:** medium (announces a retirement that may be temporary). Date-stamp makes un-retiring a one-line revert.
- **Rollback:** remove banner; `git mv` names back.
- **Note:** do NOT re-enable `sports-betting-refresh.yml` casually — it re-arms the paper auto-place path (`sports_bets.php auto_place: deny fliff/betanysports`) which has had no live exercise while off.

## Step 9 — `/audit` deploy race (RC8, separate PR)
- **File:** `.github/workflows/deploy-competition-to-site.yml` (and review `deploy-fte-index.yml`).
- **Change:** add
  ```yaml
  concurrency:
    group: ftp-deploy-audit-dashboard-${{ github.ref }}
    cancel-in-progress: false
  ```
  alongside `permissions:`.
- **Risk:** medium. This is the only `/audit` writer in a push path filter with no concurrency group.
- **Rollback:** remove the `concurrency:` block.

---

## Ordering rules
1. Steps 1–3 first (record + guardrail + timeout confirmation).
2. Steps 4–6 next (cron/concurrency), each its own PR.
3. Steps 7–9 are independent and can be parallel PRs; 8 and 9 are decision-gated and must not ride with 7.
4. Never `git push --force` to `main`. Reverts are append-only.