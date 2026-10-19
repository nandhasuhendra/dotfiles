---
title: "{{title}}: Task Breakdown"
type: task
status: draft
---

# Task Breakdown: {{title}}

| Field | Value |
| --- | --- |
| Change | <slug> |
| Approved inputs | <Applicable PRD/design/spec paths and test-plan approval references> |
| Delivery outcome | <Smallest complete, independently verifiable change> |
| Sequencing | <Dependency order and why; do not impose backend/frontend or CRUD ordering> |

Keep the installed OpenSpec schema's headings and numbered task-checkbox grammar. The checklist below is a shape example, not approved work; freeze the resulting plan after human approval and track execution in `verification.md`.

## 1. Implementation and verification

- [ ] 1.1 TASK-001 <Deliver one complete behavior linked to REQ/TC IDs>

Add only tasks needed for the change, including tests, affected consumers, documentation and rollout/rollback. Give each task one checkbox here; do not duplicate execution checklists in its details.

## Task details

### TASK-001: <Deliverable>

| Field | Value |
| --- | --- |
| Owner role | <Responsible engineering or QA role; no invented assignment> |
| Traceability | <REQ IDs, acceptance criteria, TC IDs and SEC IDs when applicable> |
| Dependencies | <Predecessor task IDs and environment prerequisites, or none> |
| Affected surface | <Source paths/callers, tests, fixtures, configuration and exports> |

#### Summary and context

- Problem: <User-visible or technical gap and source-grounded current state.>
- Deliverable: <Complete outcome and boundary; link the owning contract instead of copying it.>

#### Acceptance criteria

1. <Observable success satisfying the referenced REQ/TC.>
2. <Relevant rejection, compatibility or safe-failure invariant.>

#### Implementation notes

1. <Smallest concrete change following existing repository patterns.>
2. <Consumer/test/fixture/config updates required by the cutover.>

#### Test scenarios and evidence

| TC / REQ | Scenario reference | Required check / evidence |
| --- | --- | --- |
| <TC / REQ IDs> | <test-plan.md case; no competing expectation> | <Supported command or manual procedure and observable outcome> |

#### Risks and recovery

- Risk/blocker: <Specific uncertainty or explicitly none.>
- Recovery: <Rollback or data-preservation action; explain N/A if appropriate.>

Repeat the detail block for each checklist task. Keep details short enough to hand off independently without inventing implementation code or unsupported commands.

## Coverage and handoff

| REQ / SEC obligation | Task IDs | TC IDs | Uncovered work / blocker |
| --- | --- | --- | --- |
| <ID> | <IDs> | <IDs> | <None or explicit gap> |

- Include a runnable smoke path and independent QA/security/review handoff; all approved behavior and affected-feature regressions must be covered.
- Planned commands and unchecked tasks are not execution results. Keep actual commands, exit codes and current-source evidence in `verification.md`.
- Next: independent tasks review, OpenSpec validation and explicit human tasks approval binding the entire planning bundle before implementation.
