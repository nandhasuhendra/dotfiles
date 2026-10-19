---
title: "{{title}}: QA Test Case Scenarios"
type: test-plan
status: draft
---

# QA Test Case Scenarios: {{title}}

| Field | Value |
| --- | --- |
| Change | <slug> |
| Approved inputs | <Spec/interview paths and current approval/review manifest references> |
| Security input | <Current independent red-team/blue-team assessment in review.md> |
| Scope / exclusions | <Changed behavior, affected existing features and justified exclusions> |

This is a test specification, not a pass report. All planned cases start NOT_RUN; execution results belong in `verification.md` without changing the approved plan.

## Environment and fixtures

| Need | Setup / prerequisite | Isolation / cleanup |
| --- | --- | --- |
| <Runtime, role, dataset or browser> | <Exact safe fixture and authorized environment> | <Reset method; no production data or real secrets> |

## Requirement and risk coverage

| REQ / acceptance criterion | SEC / risk | Scenario IDs | Coverage gap / blocker |
| --- | --- | --- | --- |
| REQ-001 / <criterion> | <SEC ID or N/A with reason> | TC-001 | <None or explicit gap> |

Split compound acceptance criteria into independently executable cases; a single happy-path row does not cover their variants.

## Test cases

### TC-001: <Observable behavior>

| Field | Value |
| --- | --- |
| Traceability | REQ-001 / <acceptance criterion>; <SEC ID if applicable> |
| Priority / layer | <Risk-based priority>; <unit, integration, browser or manual> |
| Type | <Positive, negative, boundary, security or regression> |
| Given | <Concrete identity/state, fixture values and preconditions> |
| When | <One reproducible action or failure injection> |
| Then | <Observable result and state; include what must remain unchanged> |
| Steps | <Ordered steps when Given/When/Then alone is insufficient> |
| Command / runner | <Repository-supported command or manual procedure; do not invent a runner> |
| Evidence needed | <Output, exit code, persisted-state assertion or screenshot; expected result> |
| Initial result | NOT_RUN |

Repeat the case block with stable TC IDs. Link shared setup rather than copying it into every case.

## Regression and special coverage

| Concern | Applicable scope / reason for N/A | TC IDs |
| --- | --- | --- |
| Existing-feature regressions | <Affected callers, neighboring flows and preserved behavior> | <IDs> |
| Validation and boundaries | <Invalid, empty, duplicate and limit inputs> | <IDs> |
| Security / permissions | <Red-team abuse paths and legitimate-path controls> | <IDs> |
| Failure and recovery | <Timeout/error, unchanged data and safe retry where specified> | <IDs> |
| Concurrency / migrations / performance | <Applicable invariant and measurement or N/A reason> | <IDs> |
| Browser / accessibility | <Playwright flows, loading/empty/error, keyboard/focus, viewports; or N/A reason> | <IDs> |

## Execution and release criteria

- Record each TC's actual outcome, command/exit code and evidence in `verification.md`: PASS, FAIL, BLOCKED or NOT_RUN.
- Preserve raw failure evidence; an RTK summary, screenshot or mock alone does not prove persistence or authorization.
- Require every REQ and security obligation covered, required cases PASS and independent QA/security/reviewer PASS against current source before requesting archive.

## Gaps and next gate

| Gap / unresolved decision | Impact | Required evidence / owner role |
| --- | --- | --- |
| <Missing capability or explicitly none> | <Coverage or execution limit> | <How to unblock without weakening criteria> |

Next: independent test-plan review, then explicit human test-plan approval before task planning. Unavailable tools or manual-only gaps are visible blockers, not inferred passes.
