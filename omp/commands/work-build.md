---
description: Execute approved tasks with test-driven self-correction.
---

# /work-build [slug]

Role: Autonomous Implementation Engineer (`@execution_tier`).
Rules: load `rules/core.md`, `rules/gates.md`, `rules/execution.md` and `rules/verification.md` before acting.

1. Read `openspec/changes/<slug>/tasks.md` and `design.md`. Require Gate 2 `Approved` in the current session. If approval is not available in context (including a new/resumed session), re-confirm through `ask` before any application edit; never infer it from files or task checkboxes.
2. Execute one discrete subtask at a time. Before editing, confirm the subtask's target files.
3. **Blast radius:** modify only the declared application target files; everything else is READ-ONLY.
4. **Dependencies:** install only packages approved in `design.md`, using the canonical package manager, and update the matching lockfile.
5. **Verify:** run the narrow test, linter or `tsc --noEmit` check for the subtask through RTK. For browser/UI subtasks, exercise the changed flow with the Playwright MCP (`browser_navigate`, `browser_snapshot`, `browser_click`) and record the observed result. Preserve exit codes and raw failures.
6. **Circuit Breaker:** if a repair fails twice, stop and report the blocker. Do not loop.
7. On pass, mark the subtask `- [x]` in `tasks.md` and continue.
8. Finish with `rtk proxy openspec validate <slug>` and a concise `git diff --stat` summary. Do not run the full regression suite here; `/work-ship` owns final regression. Report incomplete tasks and blockers accurately; only call it ready for `/work-ship` when every task is checked.
