# Execution Stage Rules

## 1. Strict Blast Radius
- During implementation, application changes may modify only the target files declared in the active `tasks.md` subtask; all other application files are READ-ONLY.
- Workflow metadata exception: after a subtask passes verification, update only that subtask's checkbox in `tasks.md`. Do not change its description, scope, dependencies or acceptance criteria. Scope changes return to `/work-spec`.
- Quality-only actions (`review-and-qa`, `qa-only`) are strictly read-only for project/application files. The orchestrator may create the resolved quality report directory. `code-reviewer` may write only its assigned review report; `qa-engineer` may write only its assigned QA report. No quality agent may edit application code, tests, task definitions or another agent's report.
- For slug targets, reports live under `openspec/changes/<slug>/quality/`; for no-slug targets, reports live under `.omp/quality/<sanitized-branch>/`.

## 2. Test-Driven Verification
- Validate through physical test runners and compiler/LSP diagnostics, never speculative LLM prose review.
- Run the narrow relevant check after each implementation subtask. The full existing regression suite belongs to `/work-ship`.

## 3. Circuit Breaker Protocol
- Maximum two consecutive automated attempts to repair a failing test.
- If the second attempt fails, stop immediately, preserve the failure output and request user guidance.

## 4. Clean Workspace
- Never leave scratch files, debug logs or experimental comments in the codebase.
- Keep lockfiles consistent with dependency changes.
- QA must isolate and clean up test data and temporary artifacts.
