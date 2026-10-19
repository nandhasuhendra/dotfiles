---
description: Create the human-readable Tech Doc and task breakdown.
---
## Load and gate

- Read project rules and the change's interview, PRD (when applicable), review records and approvals.
- Require fresh interview approval and, for product/mixed work, an approved PRD. Stop on stale inputs or blocking questions.
- Do not create OpenSpec artifacts or agent-ready `tasks.md` here.

## Technical planning

- Dispatch `tech-lead`; disclose if adopting the role directly.
- Read `TECH-DOC.md` and `TASK-BREAKDOWN.md`. Inspect source, repository instructions and relevant architecture to ground claims in the actual project.
- Write `design.md` for engineering/mixed work and for product work that needs technical decisions. Explain current behavior, proposed architecture, flow, rationale, alternatives, contracts, data impact, failure modes, security, compatibility, rollout and rollback in plain language.
- Write `task-breakdown.md` as a human-readable sequence of milestones/work packages, dependencies, affected areas, risks and completion outcomes. Do not make schema-specific checkboxes the primary presentation.
- Link stable REQ IDs to relevant design decisions and work packages. Avoid repeating the entire PRD. Surface decisions that require the human.
- Keep OpenSpec proposal/spec/task files absent until the human planning bundle is approved.

## Handoff

- Report documents created, source references inspected, assumptions and blocking questions.
- Continue to `/work-doc-review $1` only when documents are complete and no material question remains. Otherwise stop and ask for clarification.
