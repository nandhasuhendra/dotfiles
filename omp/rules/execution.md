# Execution Stage Rules

## 1. Strict Blast Radius
- Application changes may modify only the target files declared in the active `tasks.md` subtask; all other application files are READ-ONLY.
- Workflow metadata exception: after a subtask passes verification, update only that subtask's checkbox in `tasks.md`. Do not change its description, scope, dependencies or acceptance criteria. Scope changes return to `/work-spec`.

## 2. Test-Driven Verification
- Validate through physical test runners and compiler/LSP diagnostics, never speculative LLM prose review.
- Run the narrow relevant check after each subtask. The full existing regression suite belongs to `/work-ship`.

## 3. Circuit Breaker Protocol
- Maximum two consecutive automated attempts to repair a failing test.
- If the second attempt fails, stop immediately, preserve the failure output and request user guidance.

## 4. Clean Workspace
- Never leave scratch files, debug logs or experimental comments in the codebase.
- Keep lockfiles consistent with dependency changes.
