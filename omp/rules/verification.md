# Verification & QA Rules

## 1. Testing Contracts
- Every feature includes a verifiable test suite (unit, integration or end-to-end).
- Cover happy paths and the failure/edge cases defined in `design.md`.

## 2. Regression & Clean Workspace
- `/work-build` runs focused checks for each subtask. `/work-ship` runs the project's required regression suites, linters and typecheckers.
- Before `/work-ship`, run `rtk proxy openspec validate <slug>` and `git diff --stat`; archive only when every task is complete.

## 3. Browser Verification
- Browser/UI changes require real Playwright MCP execution of the changed happy and error flows, keyboard access and relevant viewports.
- Record the navigation, actions, snapshots and console/network observations. If Playwright is unavailable, mark the check BLOCKED; never simulate PASS.

## 4. Evidence
- Record actual commands, exit codes and observed outcomes. Missing, stale or unrun checks are not PASS.
