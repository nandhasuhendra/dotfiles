---
description: Show change status and next action.
---

# /work-status [slug]

Read-only inspection of an active change. Do not edit artifacts, run implementation checks, or advance a gate.

## Rule loading

Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md`; load `rules/gates.md` when interpreting gate state. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Inspect

- Change slug: `$1`. If the change is missing, report that fact; do not initialize a replacement.
- Read `openspec/changes/<slug>/proposal.md`, `design.md` and `tasks.md` when present.
- Run `rtk proxy openspec status --change $1` and `rtk proxy openspec validate $1` to report schema status.
- Count completed tasks from the `- [x]` checkboxes in `tasks.md`. A checked box is not proof that tests passed.
- Check whether Gate 1 and Gate 2 were explicitly confirmed through the `ask` tool. Never infer approval from silence, a prior decision, or a command invocation.

## Report

- Present `Stage | Evidence | Blocker | Next command` across spec, build and ship.
- Cite artifact paths and observed evidence; distinguish missing, stale, failed and unrun checks.
- Recommend exactly one next action:
  - `/work-spec <feature>` when no approved specification exists.
  - `/work-build <slug>` when `tasks.md` is approved but incomplete.
  - `/work-ship <slug>` when all tasks are complete and unshipped.
  - `/work-resume <slug>` when the session was interrupted.
