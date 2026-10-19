# Verification and security rules

Load with `core.md` for QA execution, verification, security review and archive.

## Independent evidence
- QA, security and final reviewer runs must be independent of the implementer and each other. If required dispatch is unavailable, record BLOCKED; do not self-review.
- Verify every approved REQ/TC and affected existing-feature regression. Record PASS/FAIL/BLOCKED/NOT_RUN per scenario, actual commands, exit codes, observed outcomes and rerunnable logs. Missing evidence is not PASS.
- Browser changes require real Playwright flows, error states, keyboard access and relevant viewport sizes. If Playwright is unavailable, browser verification is BLOCKED.
- Record implementation identity using HEAD plus a digest manifest of changed tracked files, relevant untracked files and deletions. HEAD alone is insufficient.
- Recompute source and artifact manifests after review/checks. Any changed input invalidates affected evidence and requires re-verification.

## Security review
- Independently examine trust boundaries, abuse paths, authorization, data integrity, dependency/version behavior and mitigation regressions where applicable.
- Record attack paths, evidence, mitigations and current-source verdict in review artifacts. Missing security evidence or unresolved findings blocks PASS.
- Do not claim a dependency/tool ran without a successful invocation. Mark N/A with a reason only when the concern truly does not apply.

## Archive
- Archive only after all required scenarios pass, current independent QA/security/reviewer verdicts pass, OpenSpec validation passes, no blocking defects remain, and explicit human archive authorization matches current manifests.
- Archive authorization does not authorize merge, release or deployment. Never infer authorization from silence, a generic “continue”, or a previous decision for changed inputs.
