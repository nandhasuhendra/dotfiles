# Technical Document: <project or feature>

> Template instructions: Replace angle-bracket prompts with inspected facts or clearly labeled proposals. Use `TBD — <decision owner or next step>` for blockers and `Not applicable — <reason>` only when the project truly has no relevant entity, API, event, or lifecycle for a particular section. Do not include these instructions in the finished document. Keep heading order and existing IDs stable on edits; keep task granularity proportional to the work. The PRD defines *what and why*; this document defines *how, verification, and delivery*.

| Field | Value |
| --- | --- |
| Status | Draft / In review / Approved (only if approval is confirmed) |
| Technical owner | <role or named person, if known> |
| Project / feature | <name> |
| Last updated | <date of this edit> |
| PRD | <link to PRD or TBD> |

## 1. Summary and scope

- **Problem and proposed solution:** <brief summary; link to PRD rather than duplicating all product details>
- **In scope / out of scope:** <technical boundaries and exclusions>
- **Constraints and assumptions:** <verified constraints separately from assumptions>
- **Success and acceptance:** <relevant PRD requirement IDs or explicitly labeled provisional requirements>

## 2. Current state

<Relevant components, dependencies, code paths, data flow, infrastructure, tests, and limitations. Cite inspected repository paths/docs. Identify unknowns instead of describing an unverified system as fact.>

## 3. Proposed design and diagrams

Use fenced `mermaid` blocks for diagrams so they remain editable and reviewable in Markdown. Every diagram subsection below is required. Model the actual proposed system rather than leaving generic example nodes in the finished document. Label assumptions and indicate external actors, trust boundaries, and failure paths when relevant. If a particular diagram genuinely cannot apply, explicitly say why; a high-level diagram and the main flowchart and sequence diagram should normally always be present.

### 3.1 High-level architecture diagram

<Show users/external systems, application components, storage, and the major connections and ownership boundaries. Explain what each component owns.>

```mermaid
flowchart LR
  User[User or external actor] --> UI[Entry point]
  UI --> Service[Service or component]
  Service --> Store[(Data store)]
```

### 3.2 Flowchart diagram

<Show the primary business or system workflow from trigger to outcome, including decisions and the most important failure path.>

```mermaid
flowchart TD
  Start([Trigger]) --> Validate{Decision}
  Validate -- Yes --> Success([Expected outcome])
  Validate -- No --> Failure([Error or alternate outcome])
```

### 3.3 Sequence diagram

<Show the time-ordered interactions across actors/components for the primary scenario, including response and failure behavior. Add another sequence if an important asynchronous or error flow needs it.>

```mermaid
sequenceDiagram
  actor User
  participant Client
  participant Service
  User->>Client: Start action
  Client->>Service: Send request or message
  alt Success condition
    Service-->>Client: Return result
    Client-->>User: Show outcome
  else Failure condition
    Service-->>Client: Return error
    Client-->>User: Show feedback
  end
```

### 3.4 Entity relationship diagram (ERD)

<Show affected persisted entities, keys, and cardinality. Include existing related entities when they explain the change. If no persistent entities exist or change and none are relevant, write `Not applicable — <specific reason>` instead of inventing a schema.>

```mermaid
erDiagram
  ENTITY_A ||--o{ ENTITY_B : relates_to
  ENTITY_A {
    string id PK
  }
  ENTITY_B {
    string id PK
    string entity_a_id FK
  }
```

### 3.5 Additional diagrams (when relevant)

<Add deployment topology, state machine, data lifecycle, trust boundary, or migration diagram when it makes a significant decision clearer. Cross-reference the diagram from the relevant design or delivery section.>

## 4. Data, API, and event contracts

Keep each contract subsection, even when the system has no such interface; state `Not applicable — <specific reason>` in that case. Use concrete names and examples based on verified or proposed behavior. Link existing OpenAPI, schema, or event definitions instead of duplicating their full contents, but summarize the change and its compatibility impact here.

### 4.1 Data contracts

<For each data object or persisted entity: name, producer/owner, consumer, field name, type, required/nullable/default, validation and invariants, key and relationships, sensitive-data classification, retention, schema version, and compatibility/migration behavior. Show a representative JSON/schema example when data crosses a boundary.>

| Object / field | Type | Required / nullable / default | Validation / meaning | Producer → consumer | Version / compatibility |
| --- | --- | --- | --- | --- | --- |
| <object.field> | <type> | <rule> | <invariant> | <owner → user> | <version / migration> |

### 4.2 API contracts

<For each new or changed API: protocol, method and path or operation name, purpose, caller, authentication and authorization, request (path/query/headers/body), response with status and schema, validation errors, other error codes, pagination/idempotency/rate limits where relevant, versioning, and backward compatibility. Include a representative request/response or link to the source contract.>

| API / operation | Caller and auth | Request contract | Success response | Errors | Version / compatibility |
| --- | --- | --- | --- | --- | --- |
| <method path or operation> | <role / permission> | <schema / example> | <status + schema> | <status + condition> | <impact> |

### 4.3 Event contracts

<For each emitted or consumed event: name/topic, producer, consumers, trigger, envelope/payload schema and example, schema version, ordering and delivery guarantees, idempotency/deduplication, retry/dead-letter handling, privacy, and compatibility. For systems without events, explicitly state why not applicable.>

| Event / topic | Producer → consumer | Trigger | Payload / schema version | Delivery, ordering, retries | Compatibility |
| --- | --- | --- | --- | --- | --- |
| <name> | <producer → consumers> | <when> | <fields + version> | <guarantees / failure policy> | <impact> |

### 4.4 Other interfaces and quality attributes

<Describe third-party integrations, files, jobs, UI states, and configuration contracts where relevant. Address security/privacy, accessibility, performance, reliability, observability, maintainability, and cost in proportion to the change. State measurable limits only when known.>

## 5. Decisions and alternatives

| Decision ID | Options considered | Chosen approach and reason | Tradeoff / consequence | Status |
| --- | --- | --- | --- | --- |
| DEC-001 | <options> | <choice or TBD> | <consequence> | Proposed / Decided / Open |

## 6. Migration, rollout, and rollback

- **Compatibility and migration:** <schema/data/API transition, backfill, and existing-client impact>
- **Release sequence and prerequisites:** <order of steps, environments, config, approvals, feature flags if needed>
- **Validation and monitoring:** <health checks, signals, and go/no-go gates>
- **Rollback and recovery:** <reversal steps and known irreversibility>

## 7. Verification plan

| Requirement ID | Verification level and scenario | Owner role | Evidence / release gate |
| --- | --- | --- | --- |
| PRD-001 | <unit / integration / E2E / manual; expected outcome> | <role> | <check or artifact> |

<Include failure, authorization, migration, and regression scenarios when relevant; distinguish planned tests from executed evidence.>

## 8. Risks, dependencies, and open questions

| Type | Item | Impact | Mitigation / decision needed | Owner role | Status |
| --- | --- | --- | --- | --- | --- |
| Risk / Dependency / Question | <item> | <impact> | <action> | <role> | Open / Resolved |

## 9. Task breakdown

Write the breakdown as **Asana-ready delivery slices and per-task blocks** so every task is directly copy-pasteable into Asana: copy the task heading and block into one Asana parent task; checkbox lines become subtasks. Relative sizes only (S/M/L or `Unknown — <reason>`), never invented dates or day estimates; dependencies refer to stable task IDs; unresolved decisions block dependent work, not license to guess.

- **Stable IDs:** use `TASK-001`, `TASK-002`, etc., and assign each one a delivery code so ownership is explicit at a glance: **PM** = Product Manager, **ARCH** = Architect, **BE** = Backend, **FE** = Frontend, **QA** = QA, **OPS** = DevOps, **LEAD** = Team Leader (e.g. `TASK-006 = BE-2`). Keep the mapping explicit so no prior `TASK-` reference dangles.
- **Every task title MUST start with an action verb** (Define, Design, Implement, Migrate, Test, Validate, Deploy, Document, Build, Reconcile, Verify, Prepare, Record). Do not start titles with nouns such as `API`, `Database`, or `Testing`.
- **Each task block requires all of:** owner role, stable `TASK-` ID, PRD requirement IDs, dependencies (`TASK-xxx` codes), deliverable, size/uncertainty, acceptance criteria, test case scenarios (IDs like `TC-<ROLE>-<task>.<n>`, with backend/API scenarios and frontend Given-When-Then as `T-FE-<task>.<n>`), and a verb-first Asana checklist with subtask IDs like `- [ ] **BE-2.1:** <verb> ...`.
- Include product decisions, diagrams/contracts, backend/frontend, QA, migration, DevOps, integration, and handoffs only where applicable.

### 9.1 Delivery slice and stable-ID mapping

Overview matrix only (do not duplicate the full task details here): each existing `TASK-` reference maps to exactly one delivery code.

| Slice | Focus | Tasks (owner role) | Stable ID mapping | Exit gate |
| --- | --- | --- | --- | --- |
| 0 | Align, discover, decide and freeze contracts | PM-1, PM-2 (Product Manager); ARCH-1, ARCH-2 (Architect) | TASK-001 = PM-1; TASK-002 = ARCH-1; ... | <reviewed decision/contract gate> |
| 1 | <storage, data and security work> | BE-1, BE-2 (Backend) | TASK-00N = BE-1; ... | <verified storage/security gate> |
| 2 | <backend service and GraphQL implementation> | BE-3, BE-4 (Backend); ARCH-3 (Architect) | TASK-00N = BE-3; ... | <reviewed API contract gate> |
| 3 | <frontend live journeys> | FE-1, FE-2 (Frontend) | TASK-00N = FE-1; ... | <live UI journey gate> |
| 4 | <verification and release gating> | QA-1, QA-2 (QA); OPS-1 (DevOps); LEAD-1 (Team Leader) | TASK-00N = QA-1; ... | <evidence and go/no-go record> |

**Parallel work and handoffs:** <tasks that may proceed together and the contract/decision required to connect them.>

**Critical path and blockers:** <dependency chain and unresolved decisions, if nontrivial.>

### 9.2 <Slice N>: <focus area>

#### 9.2.1 <ROLE>-<n>: <Verb-first task title>

**Stable ID:** <TASK-XXX> · **Owner role:** <Product Manager / Architect / Backend / Frontend / QA / DevOps / Team Leader> · **Size:** <S/M/L or Unknown — reason> · **PRD IDs:** <PRD-XXX or range>
**Dependencies:** <None or TASK-XXX (CODE-N) ...> · **Deliverable:** <reviewable artifact> · **Uncertainty:** <what could change the plan>

##### 1. Problem Statement / Context

<What problem this task solves, which verified current-state facts apply, and which decision IDs it unblocks.>

##### 2. <Contract / Validation Rules / User Flow>

<Concrete rules, matrix, or flow for this task; link or summarize the relevant §4 contracts and §5 decisions.>

##### 3. Acceptance Criteria

- <testable done condition 1>
- <testable done condition 2>
- <testable done condition 3>

##### 4. Test Case Scenarios

- **TC-<ROLE>-<task>.<n>:** <Given ... when ... then ...; or HTTP/E2E scenario for backend tasks>.
- **T-FE-<task>.<n>:** <Given-When-Then for frontend tasks; verbose enough to paste into a test tracker>.

##### 5. Sub-Tasks (Asana Checklist)

- [ ] **<ROLE>-<task>.<n>:** <verb-first step>.
- [ ] **<ROLE>-<task>.<n>:** <verb-first step>.

## 10. Change log

| Date | Change and reason | Affected decision / PRD / task IDs | Source |
| --- | --- | --- | --- |
| <date> | <change> | <IDs> | <source> |

## Technical document review checklist

- [ ] The design addresses each in-scope PRD requirement ID, or gaps are explicitly marked TBD.
- [ ] High-level architecture, flowchart, sequence, and ERD sections contain project-specific Mermaid diagrams; any truly inapplicable ERD has a specific explanation.
- [ ] Data, API, and event contract sections state concrete schemas, producers/consumers, errors or delivery behavior, and compatibility, or explicitly justify why the interface is absent.
- [ ] Current-state claims have evidence; proposed designs and assumptions are labeled.
- [ ] Interfaces, failure behavior, and relevant security/operational considerations are explicit.
- [ ] Verification covers requirements and release gates; planned versus executed checks are distinct.
- [ ] Every task has a stable `TASK-` ID mapped to an owner-coded delivery ID (PM/ARCH/BE/FE/QA/OPS/LEAD), a verb-first title, and a block containing role, PRD IDs, dependencies, deliverable, size/uncertainty, acceptance criteria, test scenarios, and an Asana-ready verb-first checklist.
- [ ] Dependencies are consistent; migration/rollout/rollback and open decisions have owners where relevant.
