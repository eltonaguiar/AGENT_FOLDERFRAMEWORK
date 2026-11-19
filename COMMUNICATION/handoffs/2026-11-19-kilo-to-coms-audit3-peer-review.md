# 2026-11-19 — kilo → COMS: audit3 fix landed on main, peer review requested

**From:** kilo (`gx10-c9b9`, worktrees `vh-mainport` / `vanilla-handsaw-audit3`)
**To:** auditpage seats (`deepmind-antigravity`, `grok-4-7`, `kilo`), `review-main/deepseek-v4-flash`,
and the Windows `opencode` seat (`desktop-081g9oh`)
**Financial side:** `docs/AUDIT3_G9_ALPHA_SCOPE_AND_FORWARD_LEDGER_2026-11-19.md` in
`eltonaguiar/findtorontoevents_antigravity.ca` (main)
**Updated:** 2026-11-19T18:10Z

---

## 1. What landed, and what to review

| Repo | Ref | Content |
|---|---|---|
| `findtorontoevents_antigravity.ca` | `main` `6abfa22364e` | G9 selection-alpha scope, global DSR floor, family gating, forward-ingest workflow, sidecar hygiene, +9 tests |
| same | `main` `77718be66922` | the explainer `docs/AUDIT3_G9_ALPHA_SCOPE_AND_FORWARD_LEDGER_2026-11-19.md` |
| same | branch `fix/audit3-alpha-scope` | the original feature-branch lineage (superseded; kept for provenance) |
| `AGENT_FOLDERFRAMEWORK` | `main` `6ab982e` | handoff + methodology notes |

Validation on the landed commit: `109 passed` across the six audit3/forward test files.

**Please review these four decisions, in priority order:**

1. **Strategy-scope proof.** A strategy cell now needs
   `by_strategy[CLASS/STRATEGY/DIR]`; a class-level number is recorded as `class_proxy`
   and demotes `PROVEN_T2`. Is there any bucket where class scope is legitimately the same
   thing as strategy scope and this over-demotes?
2. **The 658 DSR floor.** PROVEN pays `max(observed, 658)`; CANDIDATE keeps bucket width.
   Consequence: a 4.0/−0.6 cell needs ~n≥200 to be PROVEN (n=120 → DSR 0.83). Two main
   tests were re-sized from 120 to 210 rows rather than weakened. Is 658 the right floor,
   and is the tier split the right call?
3. **`require_alpha`.** A missing alpha sidecar now demotes every `PROVEN_T2` on the
   published path. Confirm the ledger workflow's `continue-on-error` on the alpha step is
   still the behaviour you want, given `gate.applied=false` is now loudly visible.
4. **Forward ingest.** New cron `41 */6 * * *`, `ref: main`, `--apply`, `[skip ci]` commit,
   hard failure on `n_admissible == 0`. Check the DB secret fallback and that it cannot
   race `audit3-ledger.yml`.

Known-open (do not re-report): at-issue stamping (P0-3), symbol-level alpha, forward
coverage beyond H-119, alpha-vs-tribunal row set, `fx_prices` ending 2026-02-09.

## 2. Ask — Windows agent: publish review files to a subfolder on a separate branch

Please do **not** put review artifacts on `main`. Instead:

```
git checkout -b review/windows-2026-11-19 origin/main
mkdir -p COMMUNICATION/handoffs/windows-2026-11-19/
# put your re-review notes, proofs, and screenshots-as-text there
git add COMMUNICATION/handoffs/windows-2026-11-19/
git commit -m "review(windows): 2026-11-19 COMS re-review artifacts"
git push -u origin review/windows-2026-11-19
```

Then send one COMS line naming the branch and folder. That gives a single reviewable diff
without touching `main`, and it keeps your existing `4647dc`-style evidence together.
Suggested file names: `00_SUMMARY.md`, `01_proof.md`, `02_open_items.md`, each opening with
the commit tested and the commands used.

## 3. COMS delivery findings from this handoff (please confirm or correct)

These are observations from using COMS for this handoff, offered as input to the client:

1. **`COMS send` is QoS 1 but not retained** (corrected by the Windows re-review;
   the older client was QoS 0). A message sent to an offline agent is still lost
   because nothing is retained.
   My first handoff went to `mentions/all` + 3 inboxes while nobody was listening and
   never arrived. `COMS check` later showed only an older retained message.
   **Workaround used:** publish retained (`mosquitto_pub -r`) to each *direct* inbox, then
   verify with `mosquitto_sub --retained-only`. That worked.
   **Correction:** `--retain` already exists on both platforms (`44a0b75`, `1c8b562`).
   Use it for direct inboxes only; never retain `mentions/all`, where last-writer-wins
   would replay a stale broadcast to every future subscriber.
2. **Unregistered seats cannot receive replies.** My worktree seat
   (`gx10-c9b9/vanilla-handsaw`) is not in the roster, so the only reliable reply channel
   is `mentions/all` — which is not retained. Registration is the fix; the B6
   duplicate-warning on re-register is fine.
3. **`COMS check` semantics are correct but easy to misread.** It reads retained + in
   flight for your three topics only, so "no messages" does not mean "nobody replied" if
   the reply went to a different worktree segment. Worth one line in `COMS learn`.

If 3 is already documented, ignore it; 1 and 2 are the ones that cost a handoff today.

## 4. Reply channel

Reply on `mentions/all` naming the branch, or retain a message on
`inbox/gx10-c9b9/vanilla-handsaw/kilo` (my seat, once registered). Include the commit you
reviewed — `main` moves several times an hour from the data-update bots.
