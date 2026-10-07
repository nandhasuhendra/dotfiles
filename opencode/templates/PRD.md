# Product Requirements Document (PRD): <project or feature>

> Template instructions: Replace angle-bracket prompts with verified information. Use `TBD — <decision owner or next step>` for unresolved items; use `Not applicable — <reason>` for irrelevant sections. Do not include these instructions in the finished PRD. Keep headings and requirement IDs stable when revising an existing document. Prefer a short, complete PRD over speculative filler.

| Field | Value |
| --- | --- |
| Status | Draft / In review / Approved (only if approval is confirmed) |
| Product owner | <role or named person, if known> |
| Project / feature | <name> |
| Last updated | <date of this edit> |
| Related technical document | <link or TBD> |

## 1. Executive summary

<What problem are we solving, for whom, and what outcome do we want? Keep it to a few sentences.>

## 2. Problem and evidence

- **Current experience / pain point:** <what happens today>
- **Evidence:** <observations, research, feedback, data, or explicitly labeled assumptions; include sources if available>
- **Why now:** <trigger or priority rationale, if known>

## 3. Users and journeys

| User / role | Need and context | Primary journey | Important edge or failure case |
| --- | --- | --- | --- |
| <user> | <need> | <start → actions → outcome> | <case> |

## 4. Goals and measures of success

| Goal | Measure / observable outcome | Baseline | Target | How and when to measure |
| --- | --- | --- | --- | --- |
| <goal> | <measure> | <known value or TBD> | <agreed target or proposed target> | <method> |

<When numeric measures are unavailable, specify observable qualitative outcomes and mark proposed metrics as proposals. Do not invent baselines or targets.>

## 5. Scope and prioritization

- **First release (must have):** <what is included>
- **Later (optional):** <deferred outcomes>
- **Out of scope:** <explicit non-goals>
- **Constraints and dependencies:** <policy, budget, dates, integrations, access, etc., only if supplied or verified>

## 6. Requirements and acceptance criteria

Use stable IDs `PRD-001`, `PRD-002`, etc. Describe observable product behavior, not a particular implementation. Make acceptance criteria specific enough for QA to verify. Add rows as needed; reference the same IDs in the technical document and task breakdown.

| ID | Priority | Requirement / user outcome | Acceptance criteria | Notes / dependencies |
| --- | --- | --- | --- | --- |
| PRD-001 | Must / Should / Later | <outcome> | <Given context, when action, then observable result; include error/permission cases where relevant> | <note> |

## 7. Experience and policy rules

<Relevant navigation, content, accessibility expectations, permissions, validation, error/empty states, privacy, and business rules. Refer to designs or policy sources if they exist; mark missing decisions TBD. Use `Not applicable — <reason>` if none.>

## 8. Assumptions, risks, and open questions

| Type | Item | Impact | Decision owner / next step | Status |
| --- | --- | --- | --- | --- |
| Assumption / Risk / Question | <item> | <effect on scope or user> | <role or action> | Open / Resolved |

## 9. Release and validation expectations

- **Release approach or gates:** <product-level conditions for launch, if known>
- **How to validate outcomes:** <research, analytics, feedback, or QA evidence linked to PRD IDs>
- **Post-release review:** <what will be checked and when, if known>

## 10. Decisions and change log

| Date | Decision or change | Rationale | Impacted requirement IDs | Decided by / source |
| --- | --- | --- | --- | --- |
| <date> | <change> | <why> | <IDs> | <source or TBD> |

## PRD review checklist

- [ ] The problem, target users, first-release scope, and non-goals are clear.
- [ ] Requirements have stable IDs and observable, testable acceptance criteria.
- [ ] Claims, metrics, deadlines, and approvals have a source or are marked as assumptions/proposals.
- [ ] Unresolved product decisions have an owner or next step.
- [ ] The technical team can identify what to build without inferring hidden business rules.
