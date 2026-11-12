# Verification & QA Rules

## 1. Testing Contracts
- Every new feature must include a verifiable test suite (Unit, Integration, or End-to-End).
- Test cases must validate both happy paths and failure/edge cases defined in `design.md`.

## 2. Regression & Clean Workspace
- Run existing regression test suites to guarantee new code introduces zero breaks in existing modules.
- Ensure linters and typecheckers pass with zero warnings/errors before handing off to `/work-ship`.
