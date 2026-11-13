# Verification & QA Rules

## 1. Testing Contracts
- Every feature includes verifiable tests (unit, integration or end-to-end) for happy paths and failure/edge cases defined in `design.md`.
- Focused checks run after each implementation subtask. The full regression suite belongs to `/work-ship`.

## 2. QA Execution
- Automated QA is an independent, read-only validation of acceptance criteria and user-visible behavior; it is not a prose-only code inspection.
- Run relevant test suites and exercise API/UI flows where applicable. Browser/UI changes require real Playwright MCP execution of changed happy/error flows, keyboard access and relevant viewports.
- Record actual commands, exit codes, test outcomes and browser observations. If required infrastructure or Playwright is unavailable, mark QA BLOCKED; never simulate PASS.
- QA must not edit application code, tests, OpenSpec task checkboxes or review artifacts. Findings go to the orchestrator.

## 3. Regression & Clean Workspace
- `/work-build` runs focused checks for each task and the selected quality path. `/work-ship` runs the project's required regression suites, linters and typecheckers.
- Before `/work-ship`, run `rtk proxy openspec validate <slug>` and inspect `git diff --stat`; archive only when every task is complete and the quality gate is approved.

## 4. Evidence
- Missing, stale, blocked or unrun checks are not PASS.
- Reports must distinguish PASS, FAIL and BLOCKED and include concise reproducible evidence.
