---
name: work-human
description: Produce stakeholder-readable PRD, technical document, and task breakdown from an approved OpenSpec change without implementing application code.
---

# /work-human <slug>

Documentation-only. Require the change's current-conversation Gate 2 approval; if this is a new conversation or approval is not present, ask the user to reconfirm and stop. Read proposal.md, design.md, and tasks.md. Reuse relevant templates already present in the target repository; if none exist, author the documents directly from the approved artifacts.

Create `openspec/changes/<slug>/human/PRD.md`, `TECH-DOC.md`, and `HUMAN-TASK-BREAKDOWN.md`. Explain user problem, personas, journeys, functional/non-functional requirements, UX, domain/data model, APIs/contracts, error handling, architecture, dependencies, testing, rollout and task sequencing as relevant. Keep language readable, avoid internal agent/workflow references, remove placeholders, verify links and consistency with approved scope.

Do not change application source, tests, OpenSpec approval state, or task completion. This command adds no new approval gate and does not authorize implementation.
