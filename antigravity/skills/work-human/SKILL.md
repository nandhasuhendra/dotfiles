---
name: work-human
description: Produce stakeholder-readable PRD, technical document, task breakdown, and test plan from an approved OpenSpec change without implementing application code.
---

# /work-human <slug>

Documentation-only. If `<slug>` is omitted or ambiguous, use the built-in `ask_question` tool to ask the user which change to use. Require the change's current-conversation Gate 2 approval; if this is a new conversation or approval is not present, use `ask_question` to ask the user to reconfirm Gate 2 approval (`(Recommended) Yes — Gate 2 was Approved for this change`, `No — stop; run /work-spec first`, `Not sure — stop; run /work-status`) and stop unless confirmed.

Read `proposal.md`, `design.md`, and `tasks.md`, and use the installed templates under `~/.gemini/config/templates/{PRD,TECH-DOC,HUMAN-TASK-BREAKDOWN,TEST-PLAN}.md` (or relevant templates in the target repository).

Create `openspec/changes/<slug>/human/PRD.md`, `TECH-DOC.md`, `HUMAN-TASK-BREAKDOWN.md`, and `TEST-PLAN.md`:
- `PRD.md`, `TECH-DOC.md`, `HUMAN-TASK-BREAKDOWN.md`: explain user problem, personas, journeys, functional/non-functional requirements, Data Flow Diagram (DFD), UX, domain/data model, APIs/contracts, error handling, architecture, dependencies, rollout and task sequencing as relevant.
- `TEST-PLAN.md`: follow `templates/TEST-PLAN.md` with three simple sections: `1. Background`, `2. Pre-requisites` (business data and configuration dependencies only — companies/organizations, user personas/roles/permissions, feature settings, and upstream business data; never mention local containers/infra setup, database roles, CLI runners, or unimplemented features), and `3. Test Scenarios` (grouped by functional journey, where each scenario `- [ ] **TC-nn: <title>** — **Result:** NOT_RUN` has a checkbox, status marker `NOT_RUN` | `SUCCESS` | `FAILED` | `BLOCKED`, and concise **Given / When / Then** business steps). Keep detailed GWT test cases in `TEST-PLAN.md` rather than duplicating them inside `PRD.md`, `TECH-DOC.md`, or `HUMAN-TASK-BREAKDOWN.md`.

Keep language readable, avoid internal agent/workflow references, remove placeholders, cross-link all four documents (`PRD.md`, `TECH-DOC.md`, `HUMAN-TASK-BREAKDOWN.md`, `TEST-PLAN.md`), and verify consistency with approved scope. Anytime a question is needed, use the built-in `ask_question` tool.

Do not change application source, tests, OpenSpec approval state, or task completion. This command adds no new approval gate and does not authorize implementation.
