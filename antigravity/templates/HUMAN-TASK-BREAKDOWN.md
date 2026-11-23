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

Authoring guidance: reuse existing source-backed milestones and keep only applicable slices. Contract examples and delivery codes are organizational aids, not required architecture, containers or new work. Preserve useful acceptance detail and link source requirements rather than inventing another plan.

**Journey-per-pair rule:** every PRD user journey (`US-*`) gets exactly one BE task and one FE task. Both depend only on the frozen contract IDs in Tech Doc sections 3 and 4, never on each other. BE builds and tests against the request/response fixtures; FE builds against a mock of the same fixtures. Neither blocks the other, and both meet in staging by flipping the FE adapter from `mock` to `real`. Do not split a journey into several BE or FE tasks, and do not add a task that needs the other team's code. Contract freeze happens at Tech Doc approval, not as a task.

This human plan joins the interview and applicable PRD/design for `human-planning` approval. Afterward, execution preparation derives schema tasks alongside specs and QA coverage, preserving these milestone IDs and rationale. The [canonical gate protocol](../rules/gates.md) governs the combined `execution` approval before code; there is no standalone QA/task approval.

| Field | Value |
| :--- | :--- |
| PRD reference | [<PRD>](<relative link>) |
| Tech doc reference | [<Tech Doc>](<relative link>) |
| Contract source | Tech Doc sections 3 (API) and 4 (messages), fixtures at `<fixture path>` |
| Architecture model | <Source-confirmed structure and boundaries; reuse existing conventions> |
| Execution order | All BE and FE tasks start in parallel once contracts are frozen; QA integration follows each pair. Shared prerequisites (migrations, shared types) are named explicitly with rationale. |
| Execution evidence | <Link existing verification.md when available; no competing progress checklist here> |
| Delivery codes | **BE** backend, **FE** frontend, **QA** verification. Task numbers match the journey: `TASK-BE-01` pairs with `TASK-FE-01` and `TASK-QA-01`. |

## Engineering Management Summary

<How the work is sliced by journey, what each pair delivers independently, and why parallel execution is safe.>

### Sequencing Strategy

<Which journeys start first and why. Name any real shared prerequisite (e.g. a migration two journeys need). Default is full parallelism: BE against contract tests, FE against mocks, QA integration in staging per journey.>

### Journey Task Inventory & Traceability

| Journey (PRD US ID) | Contract IDs | BE task | FE task | QA task | REQ IDs |
| :--- | :--- | :--- | :--- | :--- | :--- |
| US-XXX-01 | CT-001, CT-002 | TASK-BE-01 | TASK-FE-01 | TASK-QA-01 | <REQ-001> |

Dependencies column intentionally absent: BE and FE tasks depend only on their contract IDs. QA task depends on its BE and FE pair.

## 1. Journey Slices

Repeat one `JNY` block per journey. Each block has exactly one BE task and one FE task.

### JNY-01: <Journey title> (US-XXX-01)

| Field | Value |
| :--- | :--- |
| Contracts | <CT-001, CT-002, EV-001 or none; links to Tech Doc sections 3.4 and 4.2> |
| Fixtures | <`<fixture path>` files for success, validation, forbidden, stale-write, empty cases> |
| Page / route | `<route>` or `N/A — no user-facing screen` |

#### TASK-BE-01: <Title>

##### Summary

<The complete, independently testable backend workflow for this journey, implementing every contract in the block above.>

##### Context

<Current gap, constraints, owning module/paths, and requirements served. Depends only on the frozen contracts.>

##### Acceptance criteria

1. Each contract request fixture is accepted or rejected as specified, and every response, including error responses, matches the contract response fixture shape.
2. <Failure/rollback condition.>
3. <Authorization, isolation or concurrency condition.>

##### Test scenarios

- Contract conformance: replay every request fixture and assert the response matches its fixture.
- <Positive path with persisted assertion.>
- <Negative/validation/denial path.>
- <Crash, retry, concurrency or rollback path where applicable.>

##### Other information

1. Contract (input and output, linked not copied):
   - Request: <CT-001 request payload/arguments>
   - Response: <CT-001 response and error codes>
   - Events/messages: <EV-001 produced or consumed, or none; link Tech Doc section 4.2>
2. Database design and queries (link the Tech Doc ERD in section 2.2 and query catalogue in 2.5; restate only what differs):
   - Tables: <tables created or changed>; queries: <Q-001, Q-002>
   ```sql
   -- Proposed statements; mark as not applied
   ```
3. Implementation guide:
   - Target files and functions (verified paths; mark new files as new).
4. Verification command:
   ```
   <repository-supported command and required environment; container only if project policy requires it>
   ```

#### TASK-FE-01: <Title>

##### Summary

<The user journey this task delivers end to end against mocked contract data, including loading, empty, error and recovery states.>

##### Context

<Current screen/data source, module ownership, and what must not change. Depends only on the frozen contracts, not on the BE task.>

##### Acceptance criteria

1. With the adapter on `mock`, the page renders every contract response fixture (success, empty, error, stale-write) correctly.
2. <Interaction and error condition; payloads sent equal the contract request fixtures.>
3. <Accessibility and responsive condition.>
4. Switching the adapter to `real` needs no component change.

##### Test scenarios

- <Rendered state assertion per response fixture.>
- <Failure/empty state assertion.>
- <Keyboard/accessible interaction assertion.>
- <Request payload assertion: what the UI sends matches the contract request schema.>

##### Other information

1. UI references:
   - <Relative screenshot paths and provenance, or `N/A — reason`>.
2. Contract usage and mock plan:
   ```typescript
   // Exact operation or hook typed from the contract; `N/A — reason` if no API change
   // Mock: adapter `mock | real` switch (<config key>) returning fixtures from <fixture path>
   ```
3. Implementation guide:
   - Target files and state handling.
4. Verification command:
   ```
   <exact command, run in mock mode>
   ```

## 2. QA & Staging Integration (QA)

One QA task per journey pair; it starts when both its BE and FE tasks are done.

### TASK-QA-01: <Title> (JNY-01)

#### Summary

<Prove at staging that the real backend honors the contract the FE mocked, and that the journey works end to end. Release authorization is separate.>

#### Acceptance criteria

1. With the FE adapter on `real`, every journey flow behaves as it did on `mock`; any response that differs from its fixture is logged as a contract change, not patched silently.
2. <Regression group.>

#### Test scenarios

- <Staging happy path through the real BE.>
- <Security/isolation negative scenario.>
- <Crash, migration, rollback or concurrency scenario.>
- <Frontend accessibility scenario in `real` mode.>

#### Other information

1. Fixtures and environment: <staging, seeded accounts; no secrets>.
2. Verification commands:
   ```
   <exact commands>
   ```
3. Evidence destination: record real results in the change verification record; do not mark complete without evidence.

## Completion Criteria

- <Outcome that must be true, linked to REQ IDs.>
- Every journey has one completed BE task, one completed FE task and one QA staging pass against the same frozen contracts, with no unrecorded contract drift.
- <Migration, compatibility, documentation and operational outcomes.>
- <Independent review and QA evidence required before completion.>

## Boundaries

- Out of scope: <Explicit exclusions from the approved PRD/Tech Doc.>
- This is a human milestone plan, not a permanent duplicate execution checklist. Derive linked schema tasks and TC references during combined execution preparation; keep actual progress/results in `verification.md`.
- Nothing here is implemented or verified until real evidence exists. Stable-checkpoint targeted author checks do not replace separate independent final QA/reviewer and risk-required security checks. Review-ready is not human acceptance, archive, PR or deployment permission.
- Source documents: <PRD and Tech Doc links>.
