---
description: Show change status and next action.
---

# /work-status [slug]

Read-only inspection of an active change. Do not edit artifacts, run implementation checks, or advance a gate.

## Rule loading

Read installed shared `RULES.md` and apply the activation check there. Read `rules/core.md`; load `rules/gates.md` and `rules/review.md` when interpreting quality state. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Inspect

- Change slug: `$1`. If supplied, inspect that exact OpenSpec change; if missing, inspect current branch-scoped evidence under `.reviews/quality/<sanitized-branch>/`.
- For a no-slug inspection, resolve the current branch and its PR/default comparison base using the same rules as `/work-build review-and-qa`. Do not infer an arbitrary OpenSpec change.
- Read available `proposal.md`, `design.md`, `tasks.md` and quality reports from the resolved path.
- Run `rtk openspec status --change <slug>` and `rtk openspec validate <slug>` only when a slug exists.
- Read-only scope check: run `rtk openspec list` and `rtk openspec list --specs`. Report the active spec count and flag any active change outside the approved scope for this repository (currently the work-schedule family). Diagnose only — do not edit, create or archive anything.
- Count completed tasks from `- [x]` checkboxes. A checked box is not proof that tests passed.
- When the change is in the spec stage, report `review/security.md` and `review/engineering.md` status, open P0/P1 findings and fingerprint freshness alongside the artifacts; missing, stale, `BLOCKED` or `CHANGES_REQUESTED` review evidence means Gate 2 is not ready.
- Report review, QA and security artifacts independently: PASS, FAIL, BLOCKED, not_triggered, missing, or stale relative to the full branch + working-tree fingerprint. For `security.md`, report the trigger decision, profile, verdict, confirmed severity counts, needs-validation count, validator results and run directory.
- Gate 1, Gate 2 and final quality approval are session-local. Never infer approval from files, reports, silence, a prior decision or a command invocation. If approval state is unknown, recommend `/work-resume`.

## Report

- Present `Stage | Evidence | Blocker | Next command` across spec, build, quality and ship.
- Cite artifact paths and observed evidence; distinguish missing, stale, failed and unrun checks.
- Recommend exactly one next action:
  - `/work-spec <feature>` when no approved specification exists.
  - `/work-build <slug>` when Gate 2 is known in this session and tasks remain.
  - `/work-build <slug> review-and-qa` or `/work-build review-and-qa` when full automated quality evidence, including triggered security evidence, is missing/stale.
  - `/work-build <slug> qa-only` or `/work-build qa-only` when only QA evidence is missing/stale and the user explicitly wants QA alone.
  - `/work-resume <slug>` when gate/quality state is unknown or the session was interrupted.
  - `/work-ship <slug>` or `/work-ship` only when all required work is complete and the user explicitly confirms review of the current diff in this session.
