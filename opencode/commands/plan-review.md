---
description: Review technical document, task breakdown, dependencies, and execution readiness
agent: team-leader
---

You are the Engineering Team Leader. Your mission is to perform an exhaustive, multi-dimensional review of the technical document, implementation plan, architecture specification, or task breakdown provided below or in the current workspace.

## Target & Input Context
Target Document / File Path / Scope:
$ARGUMENTS

## Context Discovery & Baseline
1. Identify the target document: Read the file specified in `$ARGUMENTS`, or find the latest technical document in the repository (e.g. `docs/TECH-DOC.md`, `TECH-DOC.md`, or relevant architecture notes in `.`).
2. Read the canonical template: Compare the document structure directly against `${XDG_CONFIG_HOME:-$HOME/.config}/opencode/templates/TECH-DOC.md`.
3. Locate linked PRD: Read the associated PRD (e.g. `docs/PRD.md` or `PRD.md`) to verify requirement traceability.

## Verbose Audit Checklist (Examine Every Area)

### 1. Document Structure & Template Compliance
- Check section completeness against canonical `TECH-DOC.md`: Overview, Scope & Goals, Requirements, Current State, Proposed Design, Cross-cutting Concerns, Delivery & Rollout, Decisions & Risks, Verification, and Task Breakdown.
- Verify that omitted sections have explicit `Not applicable — <reason>` justifications rather than silent deletions.

### 2. Architectural Diagrams & Visual Consistency
- Inspect the four required Mermaid diagrams:
  a. High-Level Architecture: Do component boundaries, external services, and data flows accurately reflect reality?
  b. Workflow Flowchart: Are decision branches, validation errors, and retry loops explicitly diagrammed?
  c. Sequence Diagram: Are actor/client, gateway/service, database, and third-party interactions sequenced end-to-end?
  d. ERD (Entity Relationship Diagram): Are table/entity names, primary/foreign keys, datatypes, and cardinalities specified?
- Verify consistency: Do entity names and field definitions in the ERD match the written data contracts and API schemas?

### 3. Contract Rigor & Interface Specifications
- Data contracts: Are database schema changes, migrations, indexing strategies, and rollback schemas explicitly defined?
- API contracts: Are HTTP/RPC/GraphQL methods, paths, request headers, request bodies, query params, response shapes (2xx, 4xx, 5xx), and status codes completely documented?
- Event contracts: Are event names, message broker topics, payload schemas, and idempotency mechanisms defined?
- Validation & Error handling: Are input validation rules, custom error codes, and failure responses specified?

### 4. Traceability & Scope Alignment
- Map every functional requirement ID from the PRD (`PRD-XXX`) to:
  a. Corresponding architectural component or interface.
  b. Verification and test coverage section.
  c. Specific implementation task in the task breakdown.
- Flag any orphan requirements (PRD items missing tasks) or rogue tasks (engineering tasks with no business justification).

### 5. Task Breakdown Quality Audit
- Audit every task entry against the mandatory format:
  `ID | Milestone | Task Title | Owner Role | Deliverable | Requirement IDs | Dependencies | Completion Criteria | Size`
- Check task titles: Does every single task title begin with an active imperative verb (e.g. `Define`, `Implement`, `Create`, `Refactor`, `Verify`, `Deploy`)?
- Check ownership: Are roles properly assigned (Product Manager, Architect, Backend, Frontend, QA, DevOps, Team Leader) rather than generic labels?
- Check dependencies: Verify that the dependency graph is acyclic (no circular deadlocks) and logical (e.g. migrations precede deployment; API contracts precede client integration).
- Check completion criteria: Is each completion criterion objective, observable, and verifiable (not "done" or "working")?
- Critical path: Identify which chain of tasks forms the critical path and which tasks can execute in parallel.

### 6. Operational, Security & Failure Readiness
- Observability: Are structured logging, error tracking (Sentry/Datadog), metrics, and tracing specified?
- Security & Permissions: Are authentication checks, role-based authorization, rate limiting, and secret management addressed?
- Rollout & Rollback: Are feature flags, canary/staged deployment steps, database backward compatibility, and explicit rollback triggers documented?

## Deliverable: Comprehensive Plan Review Report

Format your review into the following structured sections:
1. **Executive Summary & Verdict:** State whether the plan is `APPROVED`, `APPROVED WITH CONDITIONS`, or `NEEDS REVISION`.
2. **Template & Section Compliance Matrix:** Table showing section, status (Pass/Fail/Missing), and notes.
3. **Diagram & Contract Consistency Findings:** Detailed breakdown of any discrepancies between diagrams and contracts.
4. **Requirement Traceability Gaps:** List any unmapped `PRD-` requirements.
5. **Task Breakdown Audit:** Specific task-by-task corrections, missing dependencies, or vague acceptance criteria.
6. **Risk Analysis & Critical Path:** High-risk items, operational bottlenecks, and recommended mitigation actions.
7. **Actionable Remediation List:** Concrete, prioritized bulleted list of fixes required before engineering starts.
