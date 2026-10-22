---
description: Create traceable QA scenarios.
---
## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/planning.md`; load `rules/gates.md` for decisions. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Read existing `openspec/changes/$1/` artifacts and relevant source before editing.
- Require fresh `human-planning` approval and the derived specs from `/work-prepare`. Stop if the human bundle changed or approval is stale.
- Read `QA-TEST-CASES.md` through shared template resolution and pass its path to the author. Filled scenarios begin NOT_RUN.

## Plan scenarios

- Dispatch `qa-engineer` with the approved inputs and source impact; if dispatch is unavailable, adopt its instructions and disclose it. Review and final verification still require separate runs.
- Write `test-plan.md` with stable `TC-` IDs linked to every `REQ-`, Given/When/Then, priority, layer, fixtures/preconditions and observable expected results.
- Cover positive, negative, boundary, permissions/security, compatibility and affected-feature regressions; add concurrency, performance or migration cases when applicable. Explain N/A coverage and expose manual gaps.
- Inspect relevant source, callers and existing tests to find affected features. Use Codegraph/LSP only when dependency impact is nontrivial and Playwright only for browser-based behavior; record actual use or a brief N/A reason.
- Specify repository-supported test commands and a real smoke path; browser work requires Playwright flows, error states, keyboard access and relevant viewports. Never invent commands or claim execution.
- Do not implement application code or implementation tests.

## Handoff

- Continue to `/work-plan $1`; QA scenarios join the same execution bundle and are reviewed and approved with it. Do not request a separate test-plan approval.
- Report coverage vs gaps, assumptions, blockers and the affected-behavior changes that must return to planning.
