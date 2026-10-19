# Execution-stage rules

Load with `core.md` for implementation. Load `verification.md` for verification, security review or archive.

## Dependency use
- OpenSpec owns the change lifecycle and schema. Inspect installed help/config/schema; never guess commands or bypass validation.
- Ponytail: read its installed skill before implementation; choose the smallest complete solution while preserving validation, security, accessibility and error handling.
- Codegraph: inspect affected callers/interfaces/regression surface when relevant; confirm findings in source and refresh stale indexes.
- Context7: use version-relevant documentation for library/API/CLI decisions; record source/version and never send private code or secrets.
- Playwright: execute changed browser flows, error states, keyboard access and relevant viewports. Browser work without executable Playwright is BLOCKED, never simulated PASS.
- RTK: wrap model-facing shell commands with a supported `rtk` route. Preserve exit status and full failure evidence; compression is not verification. If unavailable/unsuitable, run the original command and record the fallback.

## Evidence
Record actual invocations and outcomes, not just tool names. Mark inapplicable tools N/A with a reason. Keep raw logs or rerunnable commands for gate checks. Do not install dependencies, alter global settings, enable unsafe browser flags or send repository data externally without authorization.

## Context efficiency
- Read complete authoritative inputs required for the current decision; scope source exploration to relevant callers, tests, fixtures, configuration and exports, then expand when evidence warrants it.
- Handoffs should carry slug, route/effort, paths and digests, REQ/TC IDs, decisions, blockers and next action—not transcript dumps or repeated full documents.
- Reuse unchanged evidence only after checking identity/freshness. A digest proves identity, not comprehension; independent reviewers must inspect authoritative inputs themselves.
- Track input/output tokens, agent calls, review loops, elapsed time and verification outcomes when available. Report unknowns as unknown; RTK output reduction is not a token benchmark.
