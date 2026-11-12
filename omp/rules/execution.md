# Execution Stage Rules

## 1. Strict Blast Radius
- The implementing agent is strictly forbidden from modifying files outside the designated target file scope declared in the active subtask of `tasks.md`.
- All other files remain strictly READ-ONLY.

## 2. Test-Driven Verification
- Code functionality is validated strictly through physical test runners and compiler/LSP diagnostics, never through speculative LLM prose reviews.

## 3. Circuit Breaker Protocol
- Maximum 2 consecutive automated attempts to fix a failing test.
- If the second attempt fails, the agent must halt (*circuit breaker trip*), prevent token waste, and request user guidance.

## 4. Zero Uncommitted Clutter
- Never leave temporary scratch files, debug logs, or experimental comments inside the codebase.
