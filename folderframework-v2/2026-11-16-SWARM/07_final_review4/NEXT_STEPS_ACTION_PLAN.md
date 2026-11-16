# NEXT_STEPS_ACTION_PLAN — folderframework-v2

**Date:** 2026-11-16  
**Status:** all four peers complete; superseded by `06_final_review3/FINAL_VERDICT.md`

This earlier action plan assumed `folderframework-v3` was still in flight. It has since landed its
librarian v2.1 (`--domains`, `validate`, multi-source `collect`), canon alignment, and round-2 findings.

**Current verdict and implementation order:** see `06_final_review3/FINAL_VERDICT.md`.

Summary of what changed vs this draft:
- v3 is **done**, not blocked.
- Final tiering: **implement now** = framework consistency + production audit claim hygiene; **pause** =
  row deletion, combo fabrication, cron sweep, sports rename, prediction persistence, real-money sizing;
  **decisions required** = dashboard authority (B2/D14), canon ratification (D1), db_freshness deletion (D3),
  sports (D4), cron scope (D6), hub-data liveness (Q2).
- Do not create new folder shapes; the librarian is chosen. Do not drive mass actions off the “235 stale”
  sampling artifact.