---
description: Read-only inspection of an active change: stage, task progress, quality evidence and one recommended next command. Does not advance gates.
---

# /work-status $ARGUMENTS

Read-only. Do not edit artifacts, run implementation checks or advance a gate.

## Inspect

1. Slug from `$ARGUMENTS`. With a slug: inspect exactly that OpenSpec change (`rtk openspec status --change <slug>` and `rtk openspec validate <slug>`; plain `openspec` only when rtk is absent). Without: resolve the current branch and its PR/default comparison base (same rules as `/work-build`), and inspect `.omp-quality/<sanitized-branch>/`. Do not infer an arbitrary OpenSpec change.
2. Read available `proposal.md`, `design.md`, `tasks.md` and quality reports at the resolved path.
3. Count completed tasks from `- [x]` checkboxes — a checked box is not proof tests passed.
4. When the change is in the spec stage, report `review/security.md` and `review/engineering.md` status, open P0/P1 findings and fingerprint freshness alongside the artifacts; missing, stale, `BLOCKED` or `CHANGES_REQUESTED` review evidence means Gate 2 is not ready.
5. Report review, QA and security evidence independently: PASS, FAIL, BLOCKED, not_triggered, missing, or stale relative to the full branch + working-tree fingerprint (base/merge-base, HEAD SHA, diff hashes, filtered status, diff stat). For `security.md`, report the trigger decision, profile, verdict, confirmed severity counts, needs-validation count, validator results and run directory.
6. Read-only scope check: `rtk openspec list` + `rtk openspec list --specs` (plain `openspec` when rtk is absent). Report active spec count and flag any active change outside the approved scope for this repository (currently the work-schedule family). Diagnose only — no edits, no archive, no gate changes.
7. Gate 1, Gate 2 and final quality approval are session-local; never infer approval from files, reports, silence or prior sessions. Unknown approval state → recommend `/work-resume`.

## Report

Present `Stage | Evidence | Blocker | Next command` across spec, build, quality and ship. Cite artifact paths and observed evidence; distinguish missing, stale, failed and unrun checks. Recommend exactly one next action:

- `/work-spec <feature>` — no approved specification exists.
- `/work-build <slug>` — Gate 2 Approved in this session and tasks remain.
- `/work-build [slug] review-and-qa` — full automated quality evidence, including triggered security evidence, is missing/stale.
- `/work-build [slug] qa-only` — only QA evidence missing/stale and the user explicitly wants QA alone.
- `/work-resume [slug]` — gate/quality state unknown or the session was interrupted.
- `/work-ship [slug]` — only when all work is complete and the quality gate is Approved in this session.
