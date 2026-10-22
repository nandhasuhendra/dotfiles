---
title: "{{title}}: QA Test Case Scenarios"
type: test-plan
status: draft
---

# QA Test Case Scenarios: {{title}}

| Field | Value |
| --- | --- |
| Change | <slug> |
| Inputs | <Approved human-planning manifest and derived schema/spec paths in the pending execution bundle> |
| Security input | <Current independent red-team/blue-team assessment, or reason specialist review is not applicable> |
| Scope / exclusions | <Changed behavior, affected existing features and justified exclusions> |

This is a test specification, not a pass report. All planned cases start NOT_RUN; execution results belong in `verification.md` without changing the approved plan.

Reuse source-backed acceptance and existing test coverage; scale sections to applicable risks without dropping REQ/TC/security or affected-feature regression obligations. This plan is prepared with derived specs and schema tasks after `human-planning` approval, not after a separate spec approval. Installed schema syntax takes precedence where applicable; the [canonical gate protocol](../rules/gates.md) governs one combined `execution` review/approval before implementation.

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

## Execution and review-ready criteria

- Record each TC's actual outcome, command/exit code and evidence in `verification.md`: PASS, FAIL, BLOCKED or NOT_RUN.
- Preserve raw failure evidence; an RTK summary, screenshot or mock alone does not prove persistence or authorization.
- Require every REQ and security obligation covered, required cases PASS, separate independent QA/reviewer PASS and risk-required security specialist PASS against current source before review-ready handoff. Required FAIL/BLOCKED/NOT_RUN or unresolved blocking findings prevents readiness. Acceptance, archive, PR and deployment remain separate decisions.

## Gaps and next gate

| Gap / unresolved decision | Impact | Required evidence / owner role |
| --- | --- | --- |
| <Missing capability or explicitly none> | <Coverage or execution limit> | <How to unblock without weakening criteria> |

Next: complete the combined execution bundle with schema tasks; independently review and validate the full bundle, then request explicit `execution` approval. No standalone test-plan approval. Unavailable tools or manual-only gaps are visible blockers, not inferred passes. Coordinated stable-checkpoint author checks may supply evidence but do not replace independent final QA.
