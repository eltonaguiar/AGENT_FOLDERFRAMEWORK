# Audit Bug Findings and Next Steps

## Bug Locations
1. **`dashboard/generate_dashboard.py`, lines 15 & 30**
   - **Bug:** Misclassifies zero unrealized P/L as negative.
   - **Fix:** Change conditional to `>=` for correct handling of break-even.

2. **`audit_systems.py`, line 35**
   - **Bug:** Treats zero PnL trades incorrectly.
   - **Fix:** Change condition to `>= 0` in wins calculation.

3. **`enhanced_audit_dashboard.py`, line 103**
   - **Bug:** Total PnL calculation aggregates incorrectly for missing fields.
   - **Fix:** Confirm all picks have correct fields before summation.

4. **`hub/data/integrated_dashboard.json`**
   - **Issue:** No active systems reported — systemic failure.
   - **Fix:** Implement status update scripts for active systems.

5. **`hub/data/winning_combos.json`**
   - **Issue:** No winning combos found.
   - **Fix:** Run algorithmic strategies for generation.

## Prioritized Work List
1. **Quick Display Fixes**:
   - Resolve `pnl_class` and display errors in `index.html` (avoid "No Data" displays).

2. **Plumbing Fixes**:
   - Update methods to ensure `integrated_dashboard` and `winning_combos` files are refreshed iteratively.

3. **Research/Strategy Work**:
   - Review panic-sell logic and test deeper impacts.
   - Run strategy evaluations for winning history.

---
*Generated reports on 2026-11-16*