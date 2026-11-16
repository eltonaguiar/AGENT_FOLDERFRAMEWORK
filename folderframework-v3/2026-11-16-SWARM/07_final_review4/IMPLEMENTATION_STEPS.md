# IMPLEMENTATION_STEPS.md — ordered, exact

> Template. Each step: exact file + function/diff description + rollback.

## Step 1 — <title>
- **File(s):** `path/to/file.py` (function `foo`)
- **Change:** (what and why; diff sketch if helpful)
- **Depends on:** —
- **Rollback:** `git revert <SHA>` / restore file X / toggle flag Y

## Step 2 — <title>
- **File(s):**
- **Change:**
- **Depends on:** Step 1
- **Rollback:**

(append steps; keep order executable top-to-bottom)
