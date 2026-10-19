---
description: Create traceable QA scenarios.
---
## Load and gate

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Read existing `openspec/changes/$1/` artifacts and relevant source before editing.
- Re-enumerate inputs and recompute upstream SHA-256 manifests. Require current human interview/spec approvals, their independent review PASS records and the complete route/schema specification bundle. Changed, missing or added upstream inputs invalidate dependent approvals/reviews/tasks/verification; stop for renewed decisions rather than silently continuing.

## Plan scenarios

- Dispatch qa-engineer with approved inputs and source impact. If author dispatch is unavailable, adopt its instructions and disclose it; this does not substitute for later independent review or verification.
- Resolve/read `QA-TEST-CASES.md` through shared template rules and provide its path/content to the scenario author. Missing templates block authoring; filled cases begin NOT_RUN.
- Use Codegraph and source confirmation to identify affected existing features; document dependency limitations under shared rules.
- Write `test-plan.md` with stable `TC-` IDs linked to every `REQ-` ID, Given/When/Then, priority, test layer, fixtures/preconditions and observable expected results.
- Cover positive, negative, boundary, permissions/security, compatibility and affected-feature regressions; add concurrency, performance and migration cases when applicable. Explain N/A coverage and expose manual gaps.
- Specify repository-supported test commands and a real smoke path. Browser changes require Playwright flows, error states, keyboard access and relevant viewport sizes. Do not invent executable commands or claim scenarios ran.
- Record specification input paths/digests, assumptions, blockers and risks. Changed expected behavior returns to spec approval rather than weakening coverage.
- Do not implement application code or implementation tests.

## Handoff

- Record coverage evidence and next gate in `test-plan.md`.
- Next: `/work-review $1 test-plan`, then `/work-approve $1 test-plan`. Stop before task planning until the human QA approval is current.
