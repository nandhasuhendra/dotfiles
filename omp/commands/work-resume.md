---
description: Resume a change at its current stage.
---

# /work-resume [slug]

Resume an interrupted session without overwriting existing work or skipping a gate.

## Rule loading

Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md`; load `rules/gates.md` and only the stage rule for the permitted work. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Reconstruct

- Change slug: `$1`. Read the change artifacts, repository instructions and current repository state.
- Run `rtk proxy openspec status --change $1` and `rtk proxy openspec validate $1` to verify current schema and artifact status.
- Identify the earliest incomplete or invalidated step: missing/revised specification, pending gate, incomplete tasks, failing tests, or unshipped change.
- Do not treat a prior approval, a checked task box, or a "resume" message as proof that current work is correct or approved.

## Resume only permitted work

- **Spec incomplete or Gate 1 pending:** continue `/work-spec` and present the Alignment Summary through `ask`.
- **Documents written but Gate 2 pending:** present the readiness report and Gate 2 through `ask`.
- **Tasks incomplete:** if Gate 2 approval is available in the current session, continue `/work-build` from the first unchecked task. Otherwise re-confirm Gate 2 through `ask`; continue only after explicit `Approved`. Respect blast radius and the Circuit Breaker.
- **Tasks complete but unshipped:** continue `/work-ship`.
- Material scope changes return to `/work-spec`; never silently expand approved scope.

## Handoff

- Report only work actually performed, observed outcomes and the next permitted command.
- Do not fabricate completion, tests, delegation, approval, archive, merge or release.
