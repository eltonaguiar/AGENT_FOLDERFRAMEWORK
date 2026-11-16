# 01_TODO/DB — pick-ledger integrity

Phase-1 focus (from charter §2 / framework §7):

- **Ghost rows**: claimed 22,947 vs dashboard "0" — find where each number is produced and why they diverge.
- **Open bloat**: 91k "open" rows vs 21 actually-active picks — define the correct filter and quantify the backlog.
- **PnL integrity**: closed-trade PnL fields consistent with TP/SL resolution.
- Candidate outcomes: data-driven Truth Layer proposal, `db_health.json` duplicate-key fix, backlog resolver design.

Write findings here while working; promote to `03_DONE/DB/` when complete with evidence attached.
