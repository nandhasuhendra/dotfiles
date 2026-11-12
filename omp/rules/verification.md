# Verification & QA Rules

## 1. Testing Contracts
- Every feature includes a verifiable test suite (unit, integration or end-to-end).
- Cover happy paths and the failure/edge cases defined in `design.md`.

## 2. Regression & Clean Workspace
- Run the existing regression suites; linters and typecheckers must pass with zero warnings or errors.
- Before `/work-ship`, run `rtk proxy openspec validate <slug>` and `git diff --stat`; archive only when every task is complete.

## 3. Evidence
- Record actual commands, exit codes and observed outcomes. Missing, stale or unrun checks are not PASS.
