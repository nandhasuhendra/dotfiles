# Execution Stage Rules

## 1. Strict Blast Radius
- Modify only the target files declared in the active `tasks.md` subtask. All other files remain strictly READ-ONLY.

## 2. Test-Driven Verification
- Validate through physical test runners and compiler/LSP diagnostics, never speculative LLM prose review.
- Run the narrow relevant check after each subtask and the existing regression suite before `/work-ship`.

## 3. Circuit Breaker Protocol
- Maximum two consecutive automated attempts to repair a failing test.
- If the second attempt fails, stop immediately, preserve the failure output and request user guidance.

## 4. Clean Workspace
- Never leave scratch files, debug logs or experimental comments in the codebase.
- Keep lockfiles consistent with dependency changes.
