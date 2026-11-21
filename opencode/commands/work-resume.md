---
description: Resume an interrupted workflow at its earliest incomplete step without overwriting work or skipping gates.
---

# /work-resume $ARGUMENTS

Reconstruct state without overwriting existing work or skipping a gate. Approval and quality decisions are session-local — never inferred from files, checked boxes, reports or prior sessions.

## Reconstruct

1. Read available change artifacts under `openspec/changes/` (with `$ARGUMENTS` as slug when given), existing quality reports (`openspec/changes/<slug>/quality/` or `.omp-quality/<sanitized-branch>/`) and the current repository diff (`git status`, `git diff --stat`, through rtk when available).
2. With a slug: `rtk openspec status --change <slug>` and `rtk openspec validate <slug>` (plain `openspec` when rtk is absent).
3. Without a slug: inspect branch-scoped quality evidence; resolve the comparison base like `/work-build` (PR base, else default branch; unambiguous only).
4. Identify the earliest incomplete or invalidated step: specification, pending gate, incomplete tasks, failing checks, missing/stale review or QA evidence, or unshipped change.
5. Report the active spec count via `openspec list --specs` and flag any active change outside the approved scope for this repository (currently the work-schedule family) (`rtk openspec list`, plain `openspec` when rtk is absent). Read-only reconstruction — do not clean up automatically.

## Resume only permitted work

- Spec incomplete or Gate 1 pending → continue `/work-spec`; present the Alignment Summary via `question`.
- Documents written, Gate 2 pending → verify `review/security.md` and `review/engineering.md` exist, match the current artifact fingerprint and are `PASS` (or only P2/P3 open); otherwise do not present Gate 2 and resume the review step in `/work-spec`. With that evidence, present readiness + Gate 2 via `question`.
- Tasks incomplete → if Gate 2 is Approved in this session, continue `/work-build <slug>`; otherwise re-confirm via `question`.
- Tasks complete, quality gate pending/unknown → continue `/work-build <slug>`; ask whether to run parallel AI review + QA or human review. Old reports are not current approval.
- Full review + QA, or triggered security evidence, missing/stale for an existing branch diff → `/work-build [slug] review-and-qa` (or branch form without slug).
- Only QA evidence requested → `/work-build [slug] qa-only`; this never completes the full ship gate.
- Quality gate approved in this session but unshipped → `/work-ship [slug]`.
- Material scope changes → return to `/work-spec`; never silently expand approved scope.

## Handoff

Report only work actually performed, observed outcomes and the next permitted command. Never fabricate completion, tests, delegation, approval, archive, merge or release.
