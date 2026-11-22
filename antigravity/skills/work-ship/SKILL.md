---
name: work-ship
description: Run final verification, enforce current quality evidence, commit and open a PR, or archive an OpenSpec change with explicit user authorization.
---

# /work-ship [slug] [git|archive|full]

This is the release orchestrator. No merge, deploy, or release. Require explicit user confirmation in the current conversation before irreversible GitHub operations. Parse mode strictly; default git.

## Mandatory quality gate

Before any ship mode that commits/pushes, resolve exact target diff and compute fingerprint (base/merge-base, HEAD, branch diff, working-tree diff, untracked files, status/stat). Require current-fingerprint PASS review and QA evidence; require security PASS when triggered. Human review may substitute only after the user explicitly confirms reviewing the current diff and acceptance criteria in this conversation. Missing, stale, FAIL, or BLOCKED evidence stops shipping. P0/P1 findings must be fixed and re-reviewed.

## git mode

Run relevant regression tests, linters and typechecks; report unavailable checks NOT_RUN. Stage only intended files, inspect staged diff, create one semantic commit, verify clean/expected state, push current branch with upstream as needed, and open PR against confirmed base branch. Do not fabricate verification. Report commit, branch, PR URL, and NOT_RUN checks.

## archive mode

Require all tasks checked, validate OpenSpec, and ask user whether to merge spec deltas or archive with skip-specs. Archive only through OpenSpec CLI; do not commit/push/open PR. Reinspect active specs and working tree.

## full mode

Require all tasks checked; run full regression, lint/typecheck, OpenSpec validation, explicit spec-effect choice and archive. Inspect staged diff, commit, verify clean, push and open PR. Report archive path, active spec count, commit, branch, PR, and NOT_RUN checks.

Never merge, deploy, or release without a separate explicit request.
