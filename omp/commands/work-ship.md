---
description: Ship work through GitHub, archive an OpenSpec change, or run the full release workflow.
---

# /work-ship [slug] [mode]

Role: Release orchestrator in the active parent session. Keep user approvals and irreversible GitHub operations in the main session; use the native `sonic` agent through `task` only for bounded mechanical checks when delegation is useful.
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

## Ship gate — human confirmation, not review evidence

Before staging, archiving, committing, pushing or opening a PR:

1. Require all tasks complete (slug modes) and the relevant checks run; report unavailable checks as `NOT_RUN` rather than blocking.
2. Review/QA/security reports under `.reviews/quality/<sanitized-branch>/` or `openspec/changes/<slug>/quality/` are advisory: summarize their findings into the PR/commit summary and into the OpenSpec change docs and human docs as a dated "Review Summary" entry, but their status never blocks shipping.
3. Use `ask` to obtain explicit confirmation that the user reviewed the current diff and verified behavior/acceptance criteria. Without that confirmation, stop. Review reports never substitute for this confirmation.
4. Never silently reuse stale reports; present them as advisory with their fingerprint noted.

## Shared preflight

1. Inspect `git status` and `git diff --stat`.
2. Identify the exact files and changes in scope. Stop if unrelated changes, scratch files, debug logs or build artifacts would be included; never silently discard or stage unrelated work.
3. Confirm the current branch and intended base branch before any GitHub operation.

## Resolve spec effect before archive

A bare `openspec archive <slug> -y` merges delta specs into `openspec/specs/`. Resolve this explicitly before every archive:

1. If `openspec/changes/<slug>/.openspec.yaml` has `skip_specs: true`, use `rtk openspec archive <slug> -y`.
2. Otherwise inspect `openspec/changes/<slug>/specs/` for delta specs:
   - No deltas → use `rtk openspec archive <slug> -y --skip-specs` so the active baseline stays untouched.
   - Deltas present → use `ask` to choose: merge deltas into active specs (normal OpenSpec), or archive with `--skip-specs` to keep the active spec set unchanged. Recommend `--skip-specs` while the active spec set is intentionally empty; merge only when the user explicitly wants a baseline spec updated.
3. Never run a bare `archive -y` on a delta-bearing change without that choice. Never move directories manually.

## Mode: git

1. Do not validate or archive OpenSpec. Reading advisory review/QA evidence is allowed.
2. Run relevant required checks for the changes being shipped. Report unavailable checks as `NOT_RUN`; never claim they passed.
3. Stage only explicitly intended files, inspect `git diff --cached`, and create one semantic commit.
4. Push the current branch to its configured remote (set upstream when needed).
5. Open a pull request against the confirmed base branch with a concise summary and actual verification evidence.
6. Report commit hash, pushed branch, PR URL and checks not run.

## Mode: archive

1. Require every task in `tasks.md` to be checked.
2. Run `rtk openspec validate <slug>` and fix schema errors.
3. Apply "Resolve spec effect before archive" and archive with the chosen command.
4. Re-inspect `git status`, `git diff --stat` and `rtk openspec list --specs`.
5. Stop without committing, pushing or opening a PR. Report archive path, active spec count and remaining working-tree changes.

## Mode: full

1. Require every task in `tasks.md` to be checked.
2. Run required regression tests, linters and typechecks. `git diff --stat` is not a test.
3. Run `rtk openspec validate <slug>` and fix schema errors.
4. Apply "Resolve spec effect before archive" and archive with the chosen command.
5. Re-inspect the diff, `rtk openspec list --specs` and confirm only intended changes remain.
6. Stage only intended files, inspect `git diff --cached`, and create one semantic commit.
7. Verify the working tree is clean, then push the current branch and open a PR against the confirmed base branch.
8. Report commit hash, archive path, active spec count, pushed branch, PR URL and checks not run.

Do not merge, deploy or release without a separate explicit request.
