---
title: "{{title}}"
type: prd
status: draft
---

# PRD: {{title}}

| Field | Value |
| --- | --- |
| Change / release scope | <slug and in-scope business outcome> |
| Inputs | <Confirmed interview and existing product/spec references> |
| Product owner / approver | <Known role/person; omit this row if unknown> |

## Problem and current behavior

- User need: <Who is affected, what fails today and why it matters.>
- Evidence: <Observed source/prototype/user report; separate facts from proposed behavior.>

| Area | Current behavior / evidence | Required behavior |
| --- | --- | --- |
| <Feature area> | <Actual observation or explicitly unknown baseline> | <Release outcome> |

## Goals and success measures

| Goal | Baseline / source | Target / observable success |
| --- | --- | --- |
| <Business outcome> | <Verified baseline or not measured> | <Confirmed measure; label unapproved targets as proposals> |

## Users and scope

| Persona | Need | Allowed actions / boundary |
| --- | --- | --- |
| <User role> | <Goal and context> | <Product-level access expectation> |

- In scope: <Capabilities and boundaries for this change.>
- Non-goals: <Explicit exclusions; do not add deferred features by default.>

## Requirements and business rules

| REQ | Requirement / invariant | Observable acceptance |
| --- | --- | --- |
| REQ-001 | <One testable capability or business rule; preserve existing IDs> | <Given context, when action, then outcome; include failure boundary> |

Include field/validation inventories and ownership/save boundaries only when the feature needs them; keep architecture choices in the Tech Doc.

## User journeys

### <Journey title>

- Persona and goal: <Starting situation, intended action and business outcome.>
- Flow: <Ordered business actions and resulting state.>
- Acceptance: <REQ IDs and independently testable success, rejection and recovery criteria.>
- UI reference, if applicable: <Existing route/mockup/capture and provenance; omit if none.>

Repeat journeys only as needed. Screenshots document observed UI, not evidence of backend correctness; never invent assets or links.

## Dependencies, assumptions and risks

| Dependency / decision | Confirmed fact or assumption | Impact / blocking question |
| --- | --- | --- |
| <External dependency or business choice> | <Source or explicitly proposed rule> | <Decision needed and owner role if known> |

## Acceptance and next gate

| Release obligation | Required evidence |
| --- | --- |
| Functional acceptance | <REQ IDs and persisted/observable outcomes to hand to QA> |
| Existing behavior | <Compatibility and affected-feature regressions> |
| Safety / access / accessibility | <Relevant business constraints; explain N/A> |

Next: independent security/spec review, then explicit human spec approval before QA scenarios. Review/approval records live in `review.md` and `approvals.md`; this draft does not grant approval.
