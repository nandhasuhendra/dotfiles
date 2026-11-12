# Verification & QA Rules

## 1. Testing Contracts
- Every feature includes a verifiable test suite (unit, integration or end-to-end).
- Cover happy paths and the failure/edge cases defined in `design.md`.

## 2. Regression & Clean Workspace
- Run the existing regression suites; linters and typecheckers must pass with zero warnings or errors.
- Before `/work-ship`, run `rtk proxy openspec validate <slug>` and `git diff --stat`; archive only when every task is complete.

## 3. Browser Verification
- Browser/UI changes require real Playwright MCP execution of the changed happy and error flows, keyboard access and relevant viewports.
- Record the navigation, actions, snapshots and console/network observations. If Playwright is unavailable, mark the check BLOCKED; never simulate PASS.

## 4. Evidence
- Record actual commands, exit codes and observed outcomes. Missing, stale or unrun checks are not PASS.
