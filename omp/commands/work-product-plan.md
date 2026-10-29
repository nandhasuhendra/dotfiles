---
description: Draft a human-readable PRD from the confirmed interview.
---

## Rule loading

- Read installed shared `RULES.md` and apply its activation check there. Read `rules/core.md` and `rules/planning.md`; load `rules/gates.md` only for bundle decisions. Resolve paths under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; stop if required policy is unreadable.

## Load and gate

- Change slug: $1. Read `interview.md` and repository context; inspect existing capability specs under `openspec/specs/` (via `rtk proxy openspec list --specs`) to ensure requirement consistency. Stop if material questions are blocking or the interview is incomplete.
- Do not generate OpenSpec change specs in this stage: human planning documents come first and are approved together as `human-planning`.
## Write the PRD

- Dispatch `product-manager`; if dispatch is unavailable, follow its role instructions and disclose the substitution.
- For product/mixed work write `prd.md` from confirmed interview evidence and source, following `PRD.md` through shared template resolution. For engineering-only work record PRD N/A in the human bundle; do not invent business requirements.
- Write for a teammate who did not join the interview: executive summary, user problem, current behavior, proposed experience, goals, non-goals, journeys, business rules, risks and measurable acceptance. Remove placeholders and unused sections.
- Preserve stable REQ IDs and distinct facts, assumptions and unresolved questions. Keep implementation architecture out unless needed to explain a user-visible constraint.
- Never continue into derived specifications, tasks or code.

## Handoff

- Continue to `/work-tech-plan $1` when no material product question blocks technical design. If a decision is needed, ask the operator, record the answer in `interview.md`, and then continue.
- The human bundle is reviewed and approved once via `/work-review $1 human-planning` → `/work-approve $1 human-planning`; do not request a separate PRD review or approval.
