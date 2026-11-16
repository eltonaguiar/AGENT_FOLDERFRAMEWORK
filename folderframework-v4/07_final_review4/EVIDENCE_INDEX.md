# EVIDENCE_INDEX — every claim → evidence

Repo: `eltonaguiar/findtorontoevents_antigravity.ca`. Base pins are **non-durable** — `origin/main`
advances ~every 60 s; re-fetch before relying on any delta. Evidence was gathered with `git`-only
(`git show origin/main:<path>`), no API/DB/browser.

## Source deliverables (this folder)
- `03_DONE/GHACTIONS/2026-11-15_21-00-33_EST_ghactions/` — 8 analysis files.
- `03_DONE/GHACTIONS/2026-11-16_02-07_EST_ghactions/` — `revert_runbook.md`, `TODOS.md`.
- Upstream commits on source repo: `ac598cefd45` (docs GHA deliverables), `db4cc06ed82` (site-impact re-verify). Both `[skip ci]`.

## Claim → evidence

| Claim | Evidence (path / SHA / command) |
|---|---|
| No push hazard on main (0 of 358) | `branch_trigger_audit.md` §2; base `eb23252219786dc09362a5a500aef2f9bc6f794f`; reproduce `python3 classify_triggers.py <repo> origin/main .github/workflows` |
| Earlier "4 whole-fleet hazards" is retracted | `branch_trigger_audit.md` §0 (those 4 have `paths:` filters → benign `B`, not hazard `H`) |
| Stale-fork: 88367 ahead / 15 behind | `revert_runbook.md` §0; `git rev-list --left-right --count HEAD...origin/main` |
| 12-row workflow delta (9 D + 1 M + 2 R) | `revert_runbook.md` §0; `git diff --name-status HEAD origin/main -- .github/workflows/` |
| 9 deletions deliberate (commit `c2393512637`) | `revert_runbook.md` §0; `git merge-base --is-ancestor c2393512637 origin/main` → false (lives on `origin/fix/disable-dead-workflows-2026-11-16`) |
| `dynamic-alpha-engine.yml` 90 vs 60 | `revert_runbook.md` §0/§2; main blob `d2ec26fef7183ad3bfb900bb29dccf15db3a6031`, HEAD blob `c2dce7bb2d41a4f0f725698b9dd31b380bf6b540`; `grep -n timeout-minutes` line 115 (main) vs 112 (HEAD) |
| Minute-0 concentration 52.5 % (189/360) | `cron_stagger_plan.md` (histogram); `cron_verification.md` (362 cron lines @ `eb23252`) |
| Worst tiers 0 */2 (15), 0 */4 (13), 0 */6 (13) | `cron_stagger_plan.md` §"Top identical cron strings"; `cron_verification.md` top tiers |
| Stagger = `zlib.crc32(name)%60`, alpha tie-break | `cron_stagger_plan.md` §"Stagger policy specification"; worked example `signal_tracking.yml` 34→35, `sign-coherence-gate.yml` 32→33 |
| 192/356 files lack `concurrency:` | `push_chain_impact.md` §"Concurrency Coverage Gap"; `cron_stagger_plan.md` |
| 26 dual-mode schedule+push files | `push_chain_impact.md` §"Push-Trigger Inventory"; `cron_stagger_plan.md` |
| 17 files branch on `github.event.schedule` (don't delete crons) | `cron_stagger_plan.md` §"Multi-cron dispatch files"; `cron_verification.md` multi-cron table |
| `/audit` delta impact = none | `site_impact_audit.md` §6.1–6.3 (per-file), §6.4 (residual risk outside delta) |
| Only unguarded `/audit` push writer = `deploy-competition-to-site.yml` | `push_chain_impact.md` §"Named Hazard"; `site_impact_audit.md` §6.4 |
| DB-freshness seam (committer manual-only, guardian artifact-only) | `orphan_items.md` Finding 1; 176-day vs ~43-day reconciliation table |
| No PHP/JS/HTML consumer of `db_freshness.json` | `orphan_items.md` Finding 1; `git grep -l 'db_freshness' origin/main -- '*.php' '*.js' '*.html'` → only Python |
| Sports frozen-but-plausible; `disabled_manually` unverified | `orphan_items.md` Finding 2 + §"Items I explicitly am not claiming"; crons still present in tree, no `.yml.disabled` rename |
| NHL goalie lib IS wired (stale comment) | `orphan_items.md` Finding 2 oddity 1: `sports_value_analyze_lib.php:7`, `sports_picks.php:9` `require_once` the goalie lib |
| 54 `/audit` deployers, 13 target `/audit` explicitly | `site_impact_audit.md` §1 inventory |
| `db-freshness-guardian.yml` is live successor | `site_impact_audit.md` §1; `orphan_items.md` Finding 1 |
| Untracked `.github/workflows/lint.yml` must not be committed | `TODOS.md` §3 (push-no-filter + references untracked `tools/agy_patch_kit.py`, `Windows/`) |

## Retractions / corrections honored (do not re-raise)
1. "4 whole-fleet-on-push hazards" → **retracted** (0 hazards; see `branch_trigger_audit.md` §0).
2. "`deploy-competition.yml` runs every ~2 min" → **retracted** (no such file; `cron_verification.md` §Retraction).
3. "`outcome-resolver.yml` consumes `db_freshness`" → **corrected** (comment only; `orphan_items.md`).
4. Pinned SHA `4645d08eee4` for the timeout restore → **not runnable** (local-only); use `origin/main` (`revert_runbook.md` §0a).

## How to reproduce any evidence item
```bash
cd /home/eaguiar2015/findtorontoevents_antigravity.ca
git fetch origin main
git diff --name-status HEAD origin/main -- .github/workflows/          # 12 rows?
git show origin/main:.github/workflows/dynamic-alpha-engine.yml | grep -n timeout-minutes
git ls-tree -r --name-only origin/main -- .github/workflows | wc -l    # 373 @ audit
```
Any number that no longer matches is **drift, not error** — re-run at the current SHA.