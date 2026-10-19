---
description: Turn approved interview findings into a human-readable PRD.
---
## Load and gate

- Read project `.omp/RULES.md` or the installed global fallback and follow all gates.
- Change slug: $1. Read `interview.md`, its review/approval records and manifest. Stop if independent interview review is not PASS, explicit human interview approval is missing, or the manifest is stale.
- Do not generate OpenSpec specs in this stage. Human planning documents come first.

## Write the PRD

- Dispatch `product-manager`; if dispatch is unavailable, follow its role instructions and disclose the substitution.
- For product/mixed work, write `prd.md` from the confirmed interview and evidence. For engineering-only work, explain in `interview.md` why a PRD is not applicable; do not invent business requirements.
- Follow `PRD.md`. Write for a teammate who did not join the interview: executive summary, user problem, current behavior, proposed experience, goals, non-goals, journeys, business rules, risks and measurable acceptance.
- Preserve stable REQ IDs. Distinguish facts, assumptions, proposals and unresolved questions. Keep technical architecture out unless needed to explain a user-visible constraint.
- Remove unused sections and placeholders. Do not author OpenSpec `proposal.md`, delta specs, agent tasks or implementation code.

## Review and checkpoint

- Independently review the PRD for clarity, completeness, scope, measurable acceptance and unanswered questions. Record findings against the current document digest.
- Present the PRD path, summary, blockers and manifest. Explicit human approval is required before technical planning.
- On `approve`, record the decision and continue to `/work-tech-plan $1`; on `approve stop`, record and stop. Reject/revisit returns to the relevant planning step; pause records nothing.
