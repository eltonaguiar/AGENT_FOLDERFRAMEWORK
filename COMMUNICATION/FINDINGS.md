# COMMUNICATION / FINDINGS

**Date:** 2026-11-16
**Source:** Analysis of eltonaguiar/AGENT_FOLDERFRAMEWORK

## Summary

The AGENT_FOLDERFRAMEWORK repository implements a Swarm / Isolated-Worktree Framework for multi-agent collaboration, originally designed for audit-system hygiene on the findtorontoevents.ca codebase.

## Current Structure

- Root README.MD contains the original protocol and a detailed review of the implemented versions.
- Versioned implementations:
  - folderframework-v2: Early attempt with dated 2026-11-16-SWARM, some final reviews, and templates.
  - folderframework-v3: Cleanest scaffold with proper phase folders (01_TODO, 03_DONE, 04_final_review, etc.), CHARTER, and domain READMEs.
  - folderframework-v4: Domain-specific execution focused on GHACTIONS.
  - folderframework: Base version.

## Key Observations from Existing Review (in README)

1. Inconsistent structure across versions (biggest practical problem).
2. Domain folders are hard-coded and not generic.
3. No enforcement mechanism for placement or validation.
4. Missing operational pieces (agent prompt templates, schema, phase transition rules).
5. Evidence and reproducibility gaps in earlier versions.
6. Phase transition rules under-specified.

## Recommendations (aligned with README review)

1. Declare folderframework-v3 as the canonical template.
2. Extend swarm_librarian.py with --domains and validate subcommand.
3. Create AGENT_PROMPT.md contract for consistent placement.
4. Add front-matter requirements for machine-readable deliverables.
5. Move high-quality work (e.g. v4 GHACTIONS) into the standard dated SWARM structure.

## Next Steps

- Implement the recommended fixes to make the framework enforceable and generic.
- Use this COMMUNICATION folder for ongoing status updates, handoffs, and cross-agent notes.

---
*Generated for persistence of findings as requested.*
