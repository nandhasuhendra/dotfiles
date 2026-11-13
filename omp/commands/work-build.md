---
description: Implement approved tasks or run targeted quality actions.
---

# /work-build [slug] [action]

Role: Autonomous Implementation Engineer (`@execution_tier`).
Executor: use the `software-engineer` custom agent, whose spawn allowlist permits only the two quality agents.
Rules: load `rules/core.md`, `rules/gates.md`, `rules/execution.md`, `rules/verification.md` and `rules/review.md` before acting.

## Parse arguments

Supported actions: `review-and-qa`, `qa-only`.

- No arguments: run the normal implementation workflow.
- One argument matching a supported action: run that quality-only action against the current branch/worktree; no slug.
- One argument that is not an action: treat it as an OpenSpec slug and run the normal implementation workflow for that change.
- Two arguments: first is the OpenSpec slug, second must be a supported action. Run that quality-only action for the slug.
- Reject unknown actions and extra arguments before making changes. Never reinterpret an unknown second argument as a slug.

Examples:
- `/work-build`
- `/work-build <slug>`
- `/work-build <slug> review-and-qa`
- `/work-build <slug> qa-only`
- `/work-build review-and-qa`
- `/work-build qa-only`

## Resolve quality target

For quality-only actions, do not implement or modify application code, tests, OpenSpec task definitions or other project files.

With a slug:
1. Require `openspec/changes/<slug>/proposal.md`, `design.md` and `tasks.md`; read them as the approved change context. Missing required artifacts means BLOCKED; do not silently fall back to another change.
2. Set the report directory to `openspec/changes/<slug>/quality/`.

Without a slug:
1. Resolve the current branch. Determine the comparison base from the open PR's base branch when an open PR exists; otherwise use the repository's configured default branch. If the base cannot be identified unambiguously, ask the user; do not guess.
2. Define the target as the complete branch diff against the merge base (`git diff <base>...HEAD`) plus current tracked/untracked working-tree changes. Include committed changes on the branch, not only `git diff HEAD`.
3. Look for an OpenSpec change clearly associated with the current branch. Use it only if exactly one match exists. Otherwise proceed without OpenSpec artifacts; do not select an arbitrary change.
4. Set the report directory to `.omp/quality/<sanitized-current-branch>/`. Create it if needed. This is local branch-scoped evidence, not an OpenSpec change.

For both forms:
- Inspect `git status --short --untracked-files=all`, the target diff, changed paths and relevant tests before dispatch.
- Exclude the report directory itself from target diff/fingerprints to prevent self-invalidating evidence.
- Capture a stable fingerprint containing base ref and merge-base SHA (when applicable), HEAD SHA, branch diff hash, working-tree diff hash, hashes of untracked files outside the report directory, filtered status and diff stat. Give the exact same target and fingerprint procedure to every agent.
- If there are no meaningful code changes, report BLOCKED/NOTHING_TO_REVIEW rather than claiming PASS.
- Create the report directory before dispatch. Agents may write only their own report there.

## Action: review-and-qa

1. Invoke OMP's `task` tool once with a single batched call using shared `context` and two `tasks` entries, each with `agent`, `task` and `solutionSpace`. Assign `code-reviewer` to inspect the target diff and `qa-engineer` to execute behavior tests. Do not invoke them sequentially.
2. Give both agents the exact target scope, base ref, diff, fingerprint and report paths. Supply OpenSpec artifacts when available; otherwise identify the PR description, commit context, existing docs and tests as the available requirements.
3. Code reviewer inspects implementation risks; QA validates behavior. Both are read-only and blocking; wait for both results.
4. Reports: `review.md` and `qa.md` in the resolved report directory.
5. Aggregate findings. If either result is FAIL, report actionable findings and stop; do not silently edit code in this quality-only action. The user can fix issues and rerun the action. If either is BLOCKED, report the blocker; never downgrade it to PASS.
6. If OMP's task tool, an agent or parallel execution is unavailable, report BLOCKED. Never claim parallel execution if it did not occur.

## Action: qa-only

1. Invoke only `qa-engineer`; do not spawn `code-reviewer`.
2. Supply the same resolved target, base, fingerprint and report path rules as above.
3. QA derives scenarios from OpenSpec acceptance criteria when available. Without OpenSpec, use available PR description, commit context, docs and existing tests. If expected behavior cannot be established sufficiently, ask one focused clarification or report BLOCKED.
4. Write only `qa.md` in the resolved report directory. QA remains read-only and must not edit code or tests.
5. Report PASS, FAIL or BLOCKED with actual commands, exit codes and observed outcomes.

## Normal implementation workflow

1. Resolve the slug from the argument or ask the user if absent; never infer an arbitrary change. Read `openspec/changes/<slug>/tasks.md` and `design.md`. Require Gate 2 `Approved` in the current session. If approval is unavailable (including a new/resumed session), re-confirm through `ask` before any application edit; never infer it from files or task checkboxes.
2. Execute one discrete subtask at a time. Before editing, confirm its declared target files.
3. **Blast radius:** modify only the declared application target files; everything else is READ-ONLY.
4. **Dependencies:** install only packages approved in `design.md`, using the canonical package manager, and update the matching lockfile.
5. **Verify:** run the narrow relevant test, linter or typecheck through RTK. For browser/UI subtasks, exercise the changed flow with Playwright MCP and record observed results. Preserve exit codes and raw failures.
6. **Circuit breaker:** after two failed repair attempts for the same check, stop and report the blocker.
7. On pass, mark only that subtask `- [x]` in `tasks.md` and continue.
8. When all tasks are checked, run `rtk proxy openspec validate <slug>` and report a concise `git diff --stat`. Do not run the full regression suite here; `/work-ship` owns final regression.

## Post-build quality choice

After implementation and focused checks are complete, use OMP's built-in `ask` tool to ask the user whether to run parallel AI review + QA or handle review manually. Never choose automatically based on diff size or perceived simplicity.

- Parallel AI review + QA: run the two agents using the same parallel procedure in `review-and-qa`.
- Human review: skip both agents, report `HUMAN_REVIEW_PENDING`, summarize the diff/checks and stop. `/work-ship` must obtain fresh explicit confirmation that the user reviewed the current diff and verified behavior/acceptance criteria.

## Completion

Report implementation checks and quality state separately. Only report `READY_FOR_SHIP` when all tasks are complete and the quality gate is approved. Quality-only actions never imply implementation completion or ship approval. A `qa-only` PASS does not satisfy a required code-review gate.
