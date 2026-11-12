---
description: Create semantic commits and archive the OpenSpec change.
---

# /work-ship [slug]

Role: Release Engineer (`@execution_tier` or `sonic`).
Rules: load `rules/core.md`, `rules/execution.md` and `rules/verification.md` before acting.

1. Inspect `git status` and `git diff --stat`; ensure no unrelated changes, scratch files, debug logs or build artifacts will be included.
2. Confirm every task in `tasks.md` is checked. If any task is incomplete, stop; do not archive.
3. Run the project's required regression tests, linters and typechecks. `git diff --stat` is not a test.
4. Run `rtk proxy openspec validate <slug>` and fix schema errors.
5. Archive with `rtk proxy openspec archive <slug> -y` (honours `skip_specs`). Do not manually move directories.
6. Re-inspect `git status` and `git diff --stat` because archive may update tracked files. Confirm the intended changes before committing.
7. Create one semantic commit:
   - Header: `feat(<slug>): <concise summary>`
   - Body: bulleted implemented components and the OpenSpec change slug.
8. Verify the working tree is clean and report the commit hash and archive path under `openspec/changes/archive/`.

Do not merge, deploy or release without a separate explicit request.
