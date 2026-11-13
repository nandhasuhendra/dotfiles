# Verification & QA Rules

## 1. Testing Contracts
- Every feature includes verifiable tests (unit, integration or end-to-end) for happy paths and failure/edge cases defined in approved `design.md` when available.
- For no-slug quality runs, derive scenarios from supplied PR/commit context, repository documentation and existing tests. If expected behavior remains ambiguous, ask for clarification or report BLOCKED.
- Focused checks run after each implementation subtask. The full existing regression suite belongs to `/work-ship`.

## 2. QA Execution
- Automated QA is an independent, read-only validation of acceptance criteria and user-visible behavior; it is not a prose-only code inspection.
- Run relevant test suites and exercise API/UI flows where applicable. Browser/UI changes require real Playwright MCP execution of changed happy/error flows, keyboard access and relevant viewports.
- Record actual commands, exit codes, test outcomes and browser observations. If required infrastructure or Playwright is unavailable, mark QA BLOCKED; never simulate PASS.
- QA must not edit application code, tests, OpenSpec task checkboxes or review artifacts. Test data/setup must be isolated and cleaned up.

## 3. Regression & Clean Workspace
- `/work-build` runs focused checks for each task and the selected quality path. `/work-ship` runs the project's required regression suites, linters and typecheckers.
- Before `/work-ship`, run `rtk proxy openspec validate <slug>` when an OpenSpec slug exists, and inspect `git diff --stat`; archive only when every task is complete and the quality gate is approved.

## 4. Evidence
- Missing, stale, blocked or unrun checks are not PASS.
- Reports must distinguish PASS, FAIL and BLOCKED and include concise reproducible evidence.
