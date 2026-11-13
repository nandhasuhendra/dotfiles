---
description: Resume a change at its current stage without skipping approval or quality gates.
---

# /work-resume [slug]

Resume an interrupted session without overwriting existing work or skipping a gate.

## Rule loading

Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md`, `rules/gates.md`, `rules/review.md` and only the stage rule for the permitted work. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Reconstruct

- Read the change artifacts, existing quality reports and current repository diff.
- Run `rtk proxy openspec status --change $1` and `rtk proxy openspec validate $1`.
- Identify the earliest incomplete or invalidated step: specification, pending gate, incomplete tasks, failing checks, missing/stale review or QA evidence, or unshipped change.
- Gate confirmations and final quality approval are session-local. Never infer them from prior approvals, checked boxes or persisted reports.

## Resume only permitted work

- **Spec incomplete or Gate 1 pending:** continue `/work-spec` and present the Alignment Summary through `ask`.
- **Documents written but Gate 2 pending:** present readiness and Gate 2 through `ask`.
- **Tasks incomplete:** if Gate 2 approval is available in this session, continue `/work-build`; otherwise re-confirm through `ask`.
- **Tasks complete but quality gate pending/unknown:** continue `/work-build`. It must ask whether to rerun parallel AI review + QA or use human review + QA. Do not treat old reports as current approval.
- **Quality gate approved in this session but unshipped:** continue `/work-ship`.
- Material scope changes return to `/work-spec`; never silently expand approved scope.

## Handoff

Report only work actually performed, observed outcomes and the next permitted command. Do not fabricate completion, tests, delegation, approval, archive, merge or release.
