# Artifact ownership

Load when deciding which artifacts are authoritative, required, or owned by a role.

## Artifacts and ownership

| Artifact | Owner | Minimum content |
| --- | --- | --- |
| `interview.md` | interviewer | Route, current/desired behavior, users, goals, constraints, non-goals, facts, assumptions, blocking questions, dependency readiness. |
| `prd.md` | product-manager | Human-readable product/mixed route: executive summary, user problem, desired experience, business rules, stable REQ IDs, measurable acceptance and success measures. |
| `design.md` | tech-lead | Human-readable technical design: current/proposed behavior, architecture rationale, alternatives, REQ IDs, impact, contracts, failure/security risks, rollout/rollback. |
| OpenSpec artifacts | product-manager + tech-lead | Installed schema's proposal and delta specs reflecting approved intent; design/tasks when required. Link REQ IDs; do not maintain competing requirements. |
| `test-plan.md` | qa-engineer | TC-to-REQ coverage, Given/When/Then, priority, layer, fixtures, expected results, affected existing-feature regression, manual gaps. |
| `task-breakdown.md` | tech-lead | Human-readable plan: milestones, approach, dependencies, risks and sequence of work. |
| `tasks.md` | tech-lead | Agent-ready OpenSpec implementation tasks linked to REQ/TC IDs, affected files, dependencies, rollout/rollback; created after QA planning. |
| `review.md` | reviewer + security-engineer | Append independent gate/security records: target, input path/digest manifest, PASS/CHANGES_REQUESTED/BLOCKED, file/line findings, risks, tool-use evidence or N/A reasons. Security records include red-team attack paths and blue-team mitigations. |
| `approvals.md` | orchestrator | Append-only human decisions binding exact artifact/input digests; never write approval on a human's behalf. |
| `verification.md` | qa-engineer + reviewer | Per TC/REQ result and real command/browser evidence, dependency invocations/results, implementation identity, regressions, review findings, remaining risks. |

- Product route requires PRD; engineering route requires design; mixed requires both. Schema-required design is still required on product work. Human approval covers the entire spec bundle, not just the PRD title.
- Questions affecting scope, expected behavior, compatibility, security or data integrity block approval. Explicitly accepted nonblocking assumptions remain visible.
- Authors may use their role instructions directly if dispatch is unavailable and disclose it. Gate review and final QA verification require independent agent runs with full context; no self-review fallback. If dispatch is unavailable, mark BLOCKED.
