---
description: Ship work through GitHub, archive an OpenSpec change, or run the full release workflow.
---

# /work-ship [slug] [mode]

Role: Release Engineer (`@execution_tier` or `sonic`).
Rules: load `rules/core.md`, `rules/execution.md` and `rules/verification.md` before acting.

## Select a mode

Supported modes:

- `git` — verify the intended changes, create a semantic commit, push the current branch, and open a pull request. Do not validate or archive OpenSpec.
- `archive` — validate and archive the OpenSpec change only. Do not commit, push, or open a pull request.
- `full` — run the complete release flow: final verification, OpenSpec validation and archive, semantic commit, push, and pull request.

If mode is omitted, use OMP's built-in `ask` tool to ask the user to choose one. Never infer a mode from the current branch, task state, or previous invocation. Reject unknown modes before making changes.

## Shared preflight

1. Inspect `git status` and `git diff --stat`.
2. Identify the exact files and changes in scope. Stop if unrelated changes, scratch files, debug logs, or build artifacts would be included; never silently discard or stage unrelated work.
3. Confirm the current branch and intended base branch before any GitHub operation.

## Mode: git

1. Do not read, validate, modify, or archive the OpenSpec change.
2. Run the relevant required checks for the changes being shipped. Report any check that is unavailable as `NOT_RUN`; never claim it passed.
3. Review the staged diff and create one semantic commit:
   - Header: `feat(<slug>): <concise summary>` when a slug is supplied; otherwise use the appropriate conventional commit scope.
   - Body: concise bullets describing the shipped changes.
4. Push the current branch to its configured remote (set upstream when needed).
5. Open a pull request against the confirmed base branch. Include a concise summary and actual verification evidence; do not claim unrun checks passed.
6. Report the commit hash, pushed branch, PR URL, and any checks not run.

## Mode: archive

1. Require every task in `tasks.md` to be checked. If any task is incomplete, stop.
2. Run `rtk proxy openspec validate <slug>` and fix schema errors.
3. Archive with `rtk proxy openspec archive <slug> -y` (honours `skip_specs`). Do not manually move directories.
4. Re-inspect `git status` and `git diff --stat` to confirm the archive result.
5. Stop without committing, pushing, or opening a pull request. Report the archive path under `openspec/changes/archive/` and the remaining working-tree changes.

## Mode: full

1. Require every task in `tasks.md` to be checked. If any task is incomplete, stop.
2. Run the project's required regression tests, linters, and typechecks. `git diff --stat` is not a test.
3. Run `rtk proxy openspec validate <slug>` and fix schema errors.
4. Archive with `rtk proxy openspec archive <slug> -y` (honours `skip_specs`). Do not manually move directories.
5. Re-inspect `git status` and `git diff --stat` because archive may update tracked files. Confirm only intended changes remain.
6. Create one semantic commit:
   - Header: `feat(<slug>): <concise summary>`
   - Body: bulleted implemented components and the OpenSpec change slug.
7. Verify the working tree is clean, then push the current branch to its configured remote (set upstream when needed).
8. Open a pull request against the confirmed base branch. Include a concise summary and actual verification evidence; do not claim unrun checks passed.
9. Report the commit hash, archive path, pushed branch, PR URL, and any checks not run.

Do not merge, deploy, or release without a separate explicit request.
