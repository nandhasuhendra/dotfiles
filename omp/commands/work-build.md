---
description: Implement approved tasks, then optionally run parallel code review and QA.
---

# /work-build [slug]

Role: Autonomous Implementation Engineer (`@execution_tier`).
Rules: load `rules/core.md`, `rules/gates.md`, `rules/execution.md`, `rules/verification.md` and `rules/review.md` before acting.

## Implement

1. Read `openspec/changes/<slug>/tasks.md` and `design.md`. Require Gate 2 `Approved` in the current session. If approval is unavailable (including a new/resumed session), re-confirm through `ask` before any application edit; never infer it from files or task checkboxes.
2. Execute one discrete subtask at a time. Before editing, confirm its declared target files.
3. **Blast radius:** modify only the declared application target files; everything else is READ-ONLY.
4. **Dependencies:** install only packages approved in `design.md`, using the canonical package manager, and update the matching lockfile.
5. **Verify:** run the narrow relevant test, linter or typecheck through RTK. For browser/UI subtasks, exercise the changed flow with Playwright MCP and record observed results. Preserve exit codes and raw failures.
6. **Circuit breaker:** after two failed repair attempts for the same check, stop and report the blocker.
7. On pass, mark only that subtask `- [x]` in `tasks.md` and continue.
8. When all tasks are checked, run `rtk proxy openspec validate <slug>` and report a concise `git diff --stat`. Do not run the full regression suite here; `/work-ship` owns final regression.

## Quality approach

After implementation and focused checks are complete, use OMP's built-in `ask` tool to ask the user to choose exactly one:

- **Parallel AI review + QA:** run both specialist agents in parallel.
- **Human review + QA:** skip both agents; the user will manually review the code and verify behavior. This is appropriate for small, low-risk changes.

Never choose automatically based on diff size or perceived simplicity. Do not ask before implementation is complete.

### Parallel AI review + QA

1. Invoke OMP's `task` tool once with a single batched call using shared `context` and two `tasks` entries. Assign `code-reviewer` to review the diff and `qa-engineer` to execute the acceptance/behavior test plan; include a concrete `solutionSpace` for each. Do not invoke them sequentially.
2. Give both agents the same change slug, approved artifacts, current diff/base and relevant test commands. Their scopes are independent:
   - Code reviewer: inspect implementation quality and risks; do not run the product QA suite.
   - QA engineer: validate acceptance criteria and behavior using tests/browser; do not perform a general code review.
3. Both agents are read-only and have `blocking: true`; wait for both results. They must not edit application files, tests, OpenSpec task checkboxes or each other's reports.
4. Ensure `openspec/changes/<slug>/quality/` exists before dispatch. Each agent writes its own concise evidence report: `quality/review.md` and `quality/qa.md`.
5. Aggregate findings. If either result is `FAIL` or `BLOCKED`, do not declare the change ready to ship. Fix valid findings within the approved scope, rerun focused checks, then rerun both agents in one parallel batch. Scope changes return to `/work-spec`.
6. If OMP's task tool, an agent, required test infrastructure or parallel execution is unavailable, report `BLOCKED`. Never claim agents ran in parallel if they did not.

### Human review + QA

1. Do not spawn either agent and do not create automated review/QA reports.
2. Report `HUMAN_REVIEW_PENDING`, summarize the exact diff and checks already run, and stop. Do not call the change ready to ship.
3. Before `/work-ship` performs any action, it must use `ask` to obtain explicit confirmation that the user has manually reviewed the current code diff and verified required behavior/acceptance criteria. A prior choice of human review is not approval.

## Completion

Report implementation checks and the selected quality path separately. Only report `READY_FOR_SHIP` when all tasks are complete and the quality gate is PASS (automated) or the user explicitly confirms manual review + QA at the ship gate. Otherwise report the exact pending/blocked state.
