---
description: Resume a change at its current stage without overwriting existing work or skipping approval gates.
---

# /work-resume [slug]

Resume an interrupted session without overwriting existing work or skipping a gate.

## Rule loading

Read installed shared `RULES.md` and apply the activation check there. Read `rules/core.md`, `rules/gates.md`, `rules/review.md` and only the stage rule for the permitted work. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Reconstruct

- Read available change artifacts, existing quality reports and current repository diff.
- Run `rtk openspec status --change <slug>` and `rtk openspec validate <slug>` only when a slug is supplied.
- Run `rtk openspec list` and `rtk openspec list --specs` to report the active spec count and flag any active change outside the approved scope for this repository (currently the work-schedule family). This is read-only state reconstruction, not a cleanup step.
- Without a slug, inspect current branch-scoped evidence under `.reviews/quality/<sanitized-branch>/` and resolve the comparison base using `/work-build` rules.
- Identify the earliest incomplete or invalidated step: specification, pending gate, incomplete tasks, failing checks, missing/stale review or QA evidence, or unshipped change.
- Gate confirmations and final quality approval are session-local. Never infer them from prior approvals, checked boxes or persisted reports.

## Resume only permitted work

- **Spec incomplete or Gate 1 pending:** continue `/work-spec` and present the Alignment Summary through `ask`.
- **Docs written, Gate 2 pending:** present `review/security.md` and `review/engineering.md` findings as advisory context when they exist; Gate 2 is decided solely by the user through `ask`.
- **Tasks incomplete:** if Gate 2 approval is available in this session, continue `/work-build <slug>`; otherwise re-confirm through `ask`.
- **Tasks complete, review pending/unknown:** continue `/work-build <slug>` and ask whether to run parallel AI review + QA or skip review. Do not treat old reports as current review.
- **Full review + QA, or triggered security evidence, missing/stale for an existing branch diff:** run `/work-build <slug> review-and-qa` or `/work-build review-and-qa` when no slug applies.
- **Only QA evidence requested:** run `/work-build <slug> qa-only` or `/work-build qa-only`. This does not complete the full ship gate.
- **Quality gate approved in this session but unshipped:** continue `/work-ship [slug]`.
- Material scope changes return to `/work-spec`; never silently expand approved scope.

## Handoff

Report only work actually performed, observed outcomes and the next permitted command. Do not fabricate completion, tests, delegation, approval, archive, merge or release.
