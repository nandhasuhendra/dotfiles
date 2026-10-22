---
title: "Task Breakdown: {{title}}"
type: task
status: not-started # not-started | in-progress | completed | blocked
created: {{date}}
updated: {{date}}
related:
  - <prd-reference>
  - <tech-doc-reference>
tags:
  - sdlc/task
  - <module>
  - backend
  - frontend
  - multi-tenant
---

# Task Breakdown: {{title}}

Authoring guidance: reuse existing source-backed milestones and keep only applicable slices. Backend/frontend/QA headings, delivery codes and contract examples are optional organizational aids, not required architecture, CRUD order, containers or new work. Preserve useful acceptance detail and link source requirements rather than inventing another plan.

This human plan joins the interview and applicable PRD/design for `human-planning` approval. Afterward, execution preparation derives schema tasks alongside specs and QA coverage, preserving these milestone IDs and rationale. The [canonical gate protocol](../rules/gates.md) governs the combined `execution` approval before code; there is no standalone QA/task approval.

| Field | Value |
| :--- | :--- |
| PRD reference | [<PRD>](<relative link>) |
| Tech doc reference | [<Tech Doc>](<relative link>) |
| Architecture model | <Source-confirmed structure and boundaries; reuse existing conventions> |
| Execution order | <Dependency order and source-backed rationale; no required CRUD ordering> |
| Execution evidence | <Link existing verification.md when available; no competing progress checklist here> |
| Delivery codes | **BE** backend, **FE** frontend, **QA** verification |

## Engineering Management Summary

<How the work is sliced, what each slice delivers independently, and why the order is safe.>

### Sequencing Strategy

<What lands first and why; how QA can test each milestone without waiting for the whole change. Follow actual dependencies rather than a generic create/edit-first rule.>

### Vertical Task Inventory & Traceability

| Task | Outcome | REQ IDs | Dependencies |
| :--- | :--- | :--- | :--- |
| TASK-BE-01 | <Observable result> | <REQ-001> | <None / task> |
| TASK-FE-01 | <Observable result> | <REQ-00x> | <Task> |
| TASK-QA-01 | <Verification result> | <REQ-00x> | <Tasks> |

## 1. Backend Vertical Slices (BE)

### TASK-BE-01: <Title>

#### Summary

<The complete, independently testable backend workflow this task delivers.>

#### Context

<Current gap, constraints, owning module/paths, and requirements served.>

#### Acceptance criteria

1. <Observable, testable condition with boundary.>
2. <Failure/rollback condition.>
3. <Authorization, isolation or concurrency condition.>

#### Test scenarios

- <Positive path with persisted assertion.>
- <Negative/validation/denial path.>
- <Crash, retry, concurrency or rollback path where applicable.>

#### Other information

1. API contract:
   ```graphql
   # Exact signatures, inputs, payloads, or `N/A — reason`
   ```
2. Database design and queries:
   ```sql
   -- Proposed statements; mark as not applied
   ```
3. Implementation guide:
   - Target files and functions (verified paths; mark new files as new).
4. Verification command:
   ```
   <repository-supported command and required environment; container only if project policy requires it>
   ```

## 2. Frontend Vertical Slices (FE)

### TASK-FE-01: <Title>

#### Summary

<The user journey this task delivers, including loading, empty, error and recovery states.>

#### Context

<Current screen/data source, module ownership, and what must not change.>

#### Acceptance criteria

1. <Hydration/rendering condition.>
2. <Interaction and error condition.>
3. <Accessibility and responsive condition.>

#### Test scenarios

- <Rendered state assertion.>
- <Failure/empty state assertion.>
- <Keyboard/accessible interaction assertion.>

#### Other information

1. UI references:
   - <Relative screenshot paths and provenance, or `N/A — reason`>.
2. API/hook usage:
   ```typescript
   // Exact operation or hook; `N/A — reason` if no API change
   ```
3. Implementation guide:
   - Target files and state handling.
4. Verification command:
   ```
   <exact command>
   ```

## 3. QA & Verification Slices (QA)

### TASK-QA-01: <Title>

#### Summary

<What must be proven for a review-ready handoff and at which layer; release authorization is separate.>

#### Acceptance criteria

1. <Scenario group with expected outcome.>
2. <Regression group.>

#### Test scenarios

- <Transactional/integration scenario.>
- <Security/isolation negative scenario.>
- <Crash, migration, rollback or concurrency scenario.>
- <Frontend contract and accessibility scenario.>

#### Other information

1. Fixtures and environment: <disposable database, containers, seeded accounts; no secrets>.
2. Verification commands:
   ```
   <exact commands>
   ```
3. Evidence destination: record real results in the change verification record; do not mark complete without evidence.

## Completion Criteria

- <Outcome that must be true, linked to REQ IDs.>
- <Migration, compatibility, documentation and operational outcomes.>
- <Independent review and QA evidence required before completion.>

## Boundaries

- Out of scope: <Explicit exclusions from the approved PRD/Tech Doc.>
- This is a human milestone plan, not a permanent duplicate execution checklist. Derive linked schema tasks and TC references during combined execution preparation; keep actual progress/results in `verification.md`.
- Nothing here is implemented or verified until real evidence exists. Stable-checkpoint targeted author checks do not replace separate independent final QA/reviewer and risk-required security checks. Review-ready is not human acceptance, archive, PR or deployment permission.
- Source documents: <PRD and Tech Doc links>.
