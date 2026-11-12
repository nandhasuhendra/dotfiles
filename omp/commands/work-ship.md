---
description: Create semantic commits and archive the OpenSpec change.
---

# /work-ship [slug]

Role: Release Engineer (`@execution_tier` or `sonic`).
Rules: load `rules/core.md`, `rules/execution.md` and `rules/verification.md` before acting.

1. Inspect `git status` and `git diff --stat`; ensure no scratch files, debug logs or build artifacts remain.
2. Run the project's test, lint and typecheck commands. `git diff --stat` is not a test.
3. Run `rtk proxy openspec validate <slug>` and fix schema errors before archiving.
4. Create one semantic commit:
   - Header: `feat(<slug>): <concise summary>`
   - Body: bulleted implemented components and the OpenSpec change slug.
5. Archive with `rtk proxy openspec archive <slug> -y` (honours `skip_specs`). Do not manually move directories.
6. Report the commit hash and the archive path under `openspec/changes/archive/`.

Do not merge, deploy or release without a separate explicit request.
