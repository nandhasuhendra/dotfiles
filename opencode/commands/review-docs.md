---
description: Read-only security and senior-engineering review of OpenSpec docs or any Markdown design docs. Args: [scope] [output-dir]
---

# /review-docs $ARGUMENTS

Role: read-only documentation reviewer. Apply the `/work-spec` design-review contract to documents that already exist, inside or outside OpenSpec: proposals, designs, task lists, baseline specs, ADRs, RFCs, threat models, runbooks, API docs and READMEs. Never edit the documents, code or tasks.

## Arguments

- **scope** — `openspec` (default when `openspec/` exists), `active`, `archive`, `specs`, a change slug, or any path/glob (default `.` when there is no `openspec/`).
- **output-dir** — writable directory; default `.omp/reviews/<YYYY-MM-DD-HHmm>-docs/`. An absolute external path is allowed and preferred for throwaway reviews.

## Inventory

Resolve review units without guessing:

- `openspec` — `openspec/changes/*/` (excluding `archive/`), `openspec/changes/archive/*/` and `openspec/specs/**/spec.md`.
- `active` / `archive` / `specs` — that subset only.
- `<slug>` — `openspec/changes/<slug>/` or `openspec/changes/archive/<slug>/`; stop if neither exists.
- `<path-or-glob>` — the selected Markdown files. A directory means every `*.md` beneath it, excluding `.git`, `node_modules`, vendored dependencies, build output and the output directory itself; respect `.gitignore`. If the selection exceeds 40 units, ask the user to narrow it.

For each unit record the identifier, stage (`active`, `archive`, `spec`, `doc`), artifacts present, mandatory artifacts missing (only for OpenSpec change units) and the artifact fingerprint: `sha256sum proposal.md design.md tasks.md` in that fixed order for a change, or the sorted selected files otherwise. A change unit missing one of the three documents is `INCOMPLETE` in the summary, not a finding.

## Review

Dispatch `security-engineer` and `principal-engineer` in parallel per unit through the `task` tool (one batched call per unit, or a shared batch when the target accepts it). Give both the same files, the stated intent from `proposal.md` or the document itself, the fingerprint and the exact report path. Never give one reviewer the other's result.

Reports: `<output-dir>/security/<unit>.md` and `<output-dir>/engineering/<unit>.md`. Each follows the `/work-spec` Phase 3 contract:

- `Status: PASS | CHANGES_REQUESTED | BLOCKED`, the unit identifier and the artifact fingerprint.
- Findings with stable IDs (`SEC-SPEC-nnn` / `ENG-SPEC-nnn`), severity P0–P3, the affected requirement, decision, task or section, the concrete consequence or attack path, the smallest required document change and the acceptance/verification case.
- A `Reviewed scope` line and an explicit "no findings in this scope" statement; absence of findings is not proof of completeness.

**Security focus:** trust boundaries, authentication/authorization and tenant/object scoping, input validation, injection (SQL/NoSQL, OS command, template, deserialization, logs), RCE vectors (eval/dynamic code, unsafe deserialization, shell execution, template evaluation, plugin loading, user-controlled file writes), XSS/output encoding/CSP, session/CSRF/tokens, secrets and cryptography, SSRF/URL fetch, uploads/path traversal/archive extraction, rate limiting, error leakage, dependency/supply-chain exposure and LLM prompt injection when applicable.

**Engineering focus:** N+1 queries, missing indexes, unbounded scans and pagination, transaction boundaries, idempotency, concurrency, durability, migrations/backfill/rollback, backward compatibility, timeouts/retries/partial failure, API contracts and error matrix, observability, SOLID/KISS/YAGNI, testability, and task completeness with target files and verification.

**Documentation-specific checks (both reviewers):**

- Requirements with no design decision or acceptance criterion.
- Contradictions between the proposal, design, tasks and any baseline spec.
- Tasks that omit a control the design requires, or acceptance criteria that cannot detect the failure.
- Security-relevant behavior described without a named control.
- Unsafe defaults stated in the docs: string-built SQL, eval/dynamic code, shell execution, raw HTML/`innerHTML`, deserialization of untrusted data, path concatenation, permissive CORS, disabled TLS verification, wildcard IAM, secrets in env/logs, missing authz/tenant scope, missing pagination.
- Stale decisions superseded later in the same document set or by the baseline spec.
- Runbook/ADR-specific: rollback steps that cannot restore the prior state, secrets or customer data in examples, missing preconditions, undocumented operational limits.

Do not audit implementation here. When a finding needs code evidence, say so and point to `/review-security` or `/security-audit`.

## Summary

Write `<output-dir>/SUMMARY.md` with:

- Scope, units reviewed, fingerprints and the review date.
- A table: unit | stage | security status | engineering status | P0 | P1 | top blocker.
- Cross-cutting themes across units.
- A prioritized P0/P1 backlog with the smallest document change and owner action.
- Units skipped or `INCOMPLETE` with the exact reason.
- A statement that this is a document review, not a code audit, and that no-findings does not prove completeness.

## Rules

- Read-only for project files. Reviewers write only their own report under the output directory.
- Treat an absent control as a finding only when the design needs it for a named boundary; do not invent deployment behavior.
- No code execution, network access, package installs or live probes.
- `BLOCKED` when a unit's documents cannot be read or intent cannot be established — never PASS.
- Never claim a reviewer, file read or check that did not occur.

## Next action

For an active change with P0/P1 findings: revise the documents (tech-lead or manual) and re-run `/review-docs <slug>`; Gate 2 stays closed until both reviews are `PASS` or only P2/P3 items remain. For an archived, baseline or ad-hoc document: treat the findings as follow-up work, not a gate. Otherwise recommend `/work-human` or `/work-build` according to stage.
