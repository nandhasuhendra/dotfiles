# Verification and security rules

Load with `core.md` for QA execution, verification, security review and archive.

## Independent evidence
- QA and final reviewer runs must be independent of the implementer and each other. Security-engineer review must also be independent when required by the change's risk classification or findings. If required dispatch is unavailable, record BLOCKED; do not self-review.
- Verify every approved REQ/TC and affected existing-feature regression. Record PASS/FAIL/BLOCKED/NOT_RUN per scenario, actual commands, exit codes, observed outcomes and rerunnable logs. Missing evidence is not PASS.
- Browser changes require real Playwright flows, error states, keyboard access and relevant viewport sizes. If Playwright is unavailable, browser verification is BLOCKED.
- Record implementation identity using HEAD plus a digest manifest of changed tracked files, relevant untracked files and deletions. HEAD alone is insufficient.
- Recompute source and artifact manifests after review/checks. Any changed input invalidates affected evidence and requires re-verification.


## Risk-based verification depth

Use the smallest verification set that proves the approved behavior and protects the affected regression surface. Add layers according to the change, not as a blanket checklist.

| Risk / change shape | Minimum verification focus |
|---|---|
| Focused, localized, low-risk change | Relevant unit/component checks, changed-path smoke test, affected regression cases, independent QA and reviewer. |
| New behavior, cross-module flow, API/contract or integration change | Above, plus integration/contract tests, caller compatibility and relevant negative/boundary cases. |
| Browser/UI behavior | Real Playwright coverage for changed happy/error flows, keyboard access and relevant viewport sizes, plus affected regressions. |
| Schema/data migration, concurrency or performance-sensitive path | Migration/data-integrity and rollback checks; concurrency/performance tests where the stated risk warrants them. |
| Security-sensitive or credible security finding | Above as applicable, plus independent security-engineer attack-path/mitigation review and security regression scenarios. |

- The table sets a floor, not a substitute for requirement-specific cases. Map every approved REQ/TC to evidence; add tests when the impact analysis reveals a credible regression path.
- A layer may be marked N/A only with a concise reason tied to the actual change. Do not run expensive suites that cannot inform the changed path, but do not omit a required check merely to save time.
- Keep QA scenario design distinct from QA execution. A written test plan, static reasoning or successful schema validation is not proof that application behavior passed.

## Security review
- Independently examine trust boundaries, abuse paths, authorization, data integrity, dependency/version behavior and mitigation regressions when security-sensitive paths change or a credible risk is identified.
- When specialist review is required, record attack paths, evidence, mitigations and current-source verdict in review artifacts. Missing required security evidence or unresolved findings blocks PASS. Otherwise, the independent reviewer records why specialist review is N/A.
- Do not claim a dependency/tool ran without a successful invocation. Mark tools N/A with a reason when they do not materially apply to the task.

## Review-ready handoff

- Finish with readable planning documents, code-change scope, REQ/TC outcomes, regression/browser/security evidence or justified N/A, independent verdicts, current manifests, remaining risks and a concrete review path.
- Required FAIL/BLOCKED/NOT_RUN, stale evidence or blocking defects prevent review-ready status. Schema validation and author assertions are not independent behavioral proof.
- Preview/review does not require a PR, deployment or archive. Report review-ready independently of acceptance; only an explicit human acceptance closes that measure. Leave external delivery for a separate request.

## Correction-cycle accounting

Use a compact section in existing `verification.md`, not a new telemetry service or mandatory tool call. Record actual evidence when available; keep raw revisits visible instead of optimizing the classification.

Field set (keep the names stable across the plan and evidence):

- `raw revisits` — every human correction/revisit prompt, including ones excluded from the avoidable subtotal.
- `avoidable revisits` — excludes only revisits evidenced as new scope or changed preference; unknown cause stays countable and labelled.
- `raw total tokens` — all recorded workflow usage (parent, subagents, QA, review, retries) in the provider's units, or `unknown` with the missing coverage stated.
- `avoidable subtotal` — tokens in full cycles started by avoidable revisits; never presented as a complete total when requests are unknown.
- `first-pass acceptance` — yes / no / unknown, closed only by an explicit later human acceptance; silence and review-ready are not acceptance.
- `elapsed time` — start to review-ready, and start to explicit acceptance where known.
- `evidence coverage` — which cycles/requests have attributable records, and what remains unknown.

Each revisit also records its category (requirement/planning gap, implementation defect, verification gap, new scope, changed preference, clarification, unknown), the affected REQ/TC, prompt/event and provider request IDs, and its cycle boundary from the correction prompt through repairs and re-review. Count each request once across parent/children/cycles; keep input, output and cache components separate without double-counting cache already included in input. Duplicate usage IDs are not counted twice.

Preserve risk, route/model, sample and measurement boundaries for like-for-like comparison. Fixture arithmetic proves accounting behavior, not real savings; historical aggregates, RTK output reduction and schema checks are not savings evidence. Missing baseline or attribution is a stated limit, not zero.

## Archive
- Archive only after all required scenarios pass, current independent QA/reviewer verdicts pass, applicable security review passes, OpenSpec validation passes, no blocking defects remain, and explicit human archive authorization matches current manifests.
- Archive authorization does not authorize merge, release or deployment. Never infer authorization from silence, a generic “continue”, or a previous decision for changed inputs.
