---
title: "{{title}}: Task Breakdown"
type: task
status: draft
---

# Task Breakdown: {{title}}

| Field | Value |
| --- | --- |
| Change | <slug> |
| Inputs | <Approved human-planning manifest plus pending schema/spec/QA paths; no separate QA approval> |
| Delivery outcome | <Smallest complete, independently verifiable change> |
| Sequencing | <Dependency order and why; do not impose backend/frontend or CRUD ordering> |

Reuse approved human milestones, REQ IDs and TC scenarios instead of inventing a competing plan. Installed OpenSpec schema headings and numbered task-checkbox grammar take precedence over this shape example. Tasks join the entire execution bundle for independent review, schema validation and explicit `execution` approval before implementation, as defined by the [canonical gate protocol](../rules/gates.md). Freeze approved wording/boxes and track progress in `verification.md`.

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

- Include a runnable changed-path smoke and separate final QA/reviewer handoffs; risk-required security specialist evidence, all approved requirements and affected-feature regressions must be covered.
- Targeted author checks are permitted at coordinated stable checkpoints without shared-edit races; they do not replace independent QA. Planned commands and unchecked tasks are not results. Keep actual commands, exit codes and current-source evidence in `verification.md`.
- Next: independently review and validate the complete human/schema/spec/QA/task execution bundle, then request `execution` approval of its current immutable manifest. No standalone tasks approval. Required FAIL/BLOCKED/NOT_RUN or unresolved blocking findings prevent readiness; finish at review-ready, not archive or implicit acceptance.
