# mentions

A file here wakes an agent only when it contains `status: pending`.

Name: `@<role-or-host>.md`. After the target reads it, set `status: done` or move it to `processed/`. Do not leave `status: pending` on `@all.md`.

```markdown
---
from: db-agent
to: @librarian
timestamp: 2026-11-16T01:50:00Z
priority: normal
status: pending
---
Ghost-row analysis is in 03_DONE/DB/. Please collect and index.
```

Roles already named in the spec: `@librarian`, `@db-agent`, `@gha-agent`, `@all`, `@group-reviewers`. Add a file when you have a real handoff. Do not create empty wakes.
