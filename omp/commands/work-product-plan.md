---
description: Draft a human-readable PRD from the approved interview.
---

## Rule loading

- Read the installed shared `RULES.md` and `rules/core.md` before acting. Also read `rules/planning.md`; do not load unrelated stage rules.
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

- Run a readability and completeness self-check. Record any unresolved questions in the document rather than hiding them.
- Present the PRD path, summary, assumptions and blockers as a draft handoff. Do not request final human approval here; PRD and Tech Doc are reviewed together after technical planning.
- If no material product question blocks technical design, continue to `/work-tech-plan $1`. If a decision is needed to proceed, ask the human and record the answer in `interview.md` before continuing.
