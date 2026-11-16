# Synthesis — folderframework only

Participants: folderframework (librarian/synthesizer). No other subfolders were present on `eltonaguiar/AGENT_FOLDERFRAMEWORK` main at `05e6e8b`.

## Kept

- Isolated worktree + dated SWARM folder + cherry-pick of markdown only.
- Evidence rule: path, SHA, or URL, or the claim is dropped.
- Pilot limited to claim correctness on DB hygiene and Money-Ready labeling.
- Prediction markets remain shadow. Copy trading stays rejected.

## Discarded

- Mass deletion of ghost rows or open picks. Counts are real; deletion is a separate, higher-risk job with no rollback tested here.
- Persisting Kalshi/Polymarket emitter output. Conflicts with the shadow decision and was not re-measured in this drop.
- Treating `overall.banner_should_show == false` as proof the database is clean.

## Residual risks

- Single-agent synthesis. A later worktree can veto with newer evidence via its own subfolder; it must not overwrite this one.
- Local JSON may lag the live site if deploy failed. Verification step is a fetch, not another local read.
- Duplicate snapshot function may mean a fix lands in the unused copy.
