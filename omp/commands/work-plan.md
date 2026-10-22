---
description: Produce implementation task breakdown.
---
## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/planning.md`; load `rules/execution.md` when the schema or validation behavior matters, and `rules/gates.md` for decisions. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Read the change artifacts and repository conventions. Require fresh `human-planning` approval, the derived specs from `/work-prepare` and QA coverage for every `REQ-` from `/work-qa`. Stop if evidence is missing or stale.
- Inspect installed OpenSpec help, config and schema instructions before writing tasks.

## Plan tasks

- Dispatch `tech-lead` with the approved bundle; if author dispatch is unavailable, adopt its instructions and disclose it.
- Write schema-compatible `tasks.md` after QA coverage exists: small ordered implementation and test tasks with `REQ-`/`TC-` links, affected files/callers/tests/fixtures/config/exports, dependencies, acceptance evidence, compatibility work and rollout/rollback where applicable.
- Resolve `TASK-BREAKDOWN.md` through shared template resolution and use it as a content checklist within the installed schema format, not a competing plan.
- Choose the smallest complete implementation from repository conventions and confirmed source impact. Read Ponytail for approach; use Codegraph/LSP for nontrivial dependency impact and Context7 for relevant external documentation per core policy.
- Keep approved `tasks.md` wording and checkboxes frozen once approved; track execution in `verification.md`.
- Do not create application code, production configuration, migrations or implementation tests.

## Review and checkpoint

- Run installed OpenSpec validation and record the actual command and result. A validation failure blocks the bundle.
- The execution bundle is now complete (human bundle, proposal, delta specs, `test-plan.md`, `tasks.md`). Continue to `/work-review $1 execution` for the independent full-bundle review; risk-required security review and validation evidence belong to that review.
- The single execution checkpoint is `/work-approve $1 execution`. Do not request separate test-plan or tasks approvals, and do not implement before explicit execution approval.
