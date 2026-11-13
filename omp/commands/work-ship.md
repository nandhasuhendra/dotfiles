---
description: Ship work through GitHub, archive an OpenSpec change, or run the full release workflow.
---

# /work-ship [slug] [mode]

Role: Release Engineer (`@execution_tier` or `sonic`).
Rules: load `rules/core.md`, `rules/gates.md`, `rules/execution.md` and `rules/verification.md` before acting.

## Select a mode

Supported modes:

- `git` — verify the intended changes, create a semantic commit, push the current branch, and open a pull request. Do not validate or archive OpenSpec.
- `archive` — validate and archive an OpenSpec change only. Do not commit, push, or open a pull request.
- `full` — final verification, OpenSpec validation and archive, semantic commit, push, and pull request.

Argument handling:
- If the only argument is `git`, `archive` or `full`, treat it as the mode with no slug.
- Otherwise, treat the first argument as the OpenSpec slug and the second as the optional mode.
- If mode is omitted, use OMP's built-in `ask` tool to ask the user to choose one.
- Never infer a mode from the current branch, task state or previous invocation. Reject unknown modes before making changes.

## Quality gate — mandatory for every mode

Before staging, archiving, committing, pushing or opening a PR:

1. Require a Quality Gate approval from the current session.
2. If the user selected automated review + QA, require both reports to be `PASS` and the reviewed diff to remain unchanged. Reports are evidence, not approval across sessions.
3. If the user selected human review + QA, use `ask` to obtain explicit confirmation that the user has reviewed the current code diff and verified required behavior/acceptance criteria.
4. If the quality choice/approval is unknown, ask the user to confirm manual review + QA for the current diff. If they have not completed it, stop and direct them to `/work-build <slug>` to run the parallel agents or return after manual verification.
5. Any changed application diff invalidates previous review/QA results. Re-run the quality gate through `/work-build`; never silently reuse stale reports.

## Shared preflight

1. Inspect `git status` and `git diff --stat`.
2. Identify the exact files and changes in scope. Stop if unrelated changes, scratch files, debug logs or build artifacts would be included; never silently discard or stage unrelated work.
3. Confirm the current branch and intended base branch before any GitHub operation.

## Mode: git

1. Do not validate or archive OpenSpec.
2. Run relevant required checks for the changes being shipped. Report unavailable checks as `NOT_RUN`; never claim they passed.
3. Stage only explicitly intended files, inspect `git diff --cached`, and create one semantic commit.
4. Push the current branch to its configured remote (set upstream when needed).
5. Open a pull request against the confirmed base branch with a concise summary and actual verification evidence.
6. Report commit hash, pushed branch, PR URL and checks not run.

## Mode: archive

1. Require every task in `tasks.md` to be checked.
2. Run `rtk proxy openspec validate <slug>` and fix schema errors.
3. Archive with `rtk proxy openspec archive <slug> -y` (honours `skip_specs`). Do not manually move directories.
4. Re-inspect `git status` and `git diff --stat`.
5. Stop without committing, pushing or opening a PR. Report archive path and remaining working-tree changes.

## Mode: full

1. Require every task in `tasks.md` to be checked.
2. Run required regression tests, linters and typechecks. `git diff --stat` is not a test.
3. Run `rtk proxy openspec validate <slug>` and fix schema errors.
4. Archive with `rtk proxy openspec archive <slug> -y` (honours `skip_specs`).
5. Re-inspect the diff and confirm only intended changes remain.
6. Stage only intended files, inspect `git diff --cached`, and create one semantic commit.
7. Verify the working tree is clean, then push the current branch and open a PR against the confirmed base branch.
8. Report commit hash, archive path, pushed branch, PR URL and checks not run.

Do not merge, deploy or release without a separate explicit request.
