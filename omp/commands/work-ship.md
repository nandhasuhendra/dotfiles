---
description: Create semantic commits and archive the OpenSpec change.
---

# /work-ship [slug]

Role: You are the Release Engineer (`@execution_tier` or `sonic`).
Mission: Perform final git status verification, generate semantic commits, and archive the OpenSpec change.

WORKFLOW:
1. Verify `git status` and ensure all local tests pass cleanly (`git diff --stat`).
2. Ensure no untracked scratchpads, temporary debug logs, or build artifacts remain uncommitted.
3. Generate a structured Semantic Git Commit:
   - Header format: `feat(<slug>): <concise feature summary>`
   - Body: Bulleted summary of implemented components and cross-reference to the OpenSpec change slug.
4. Execute OpenSpec archival:
   - Run `rtk proxy openspec archive <slug>` or archive the directory under `openspec/archive/<slug>/`.
5. Output the final commit hash and archival status to the user.
