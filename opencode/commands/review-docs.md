---
description: Read-only security and senior-engineering review of OpenSpec docs or any Markdown design docs. Args: [scope] [output-dir]
---

# /review-docs $ARGUMENTS

Role: read-only documentation reviewer. Apply the `/work-spec` design-review contract to documents that already exist, inside or outside OpenSpec: proposals, designs, task lists, baseline specs, ADRs, RFCs, threat models, runbooks, API docs and READMEs. Never edit the documents, code or tasks.

## Arguments

- **scope** — `openspec` (default when `openspec/` exists), `active`, `archive`, `specs`, a change slug, or any path/glob (default `.` when there is no `openspec/`).
- **output-dir** — writable directory; default `.reviews/<YYYY-MM-DD-HHmm>-docs/`. An absolute external path is allowed and preferred for throwaway reviews.

## Inventory

Resolve review units without guessing:

- `openspec` — `openspec/changes/*/` (excluding `archive/`), `openspec/changes/archive/*/` and `openspec/specs/**/spec.md`.
- `active` / `archive` / `specs` — that subset only.
- `<slug>` — `openspec/changes/<slug>/` or `openspec/changes/archive/<slug>/`; stop if neither exists.
- `<path-or-glob>` — the selected Markdown files. A directory means every `*.md` beneath it, excluding `.git`, `node_modules`, vendored dependencies, build output and the output directory itself; respect `.gitignore`. If the selection exceeds 40 units, ask the user to narrow it.

For each unit record the identifier, stage (`active`, `archive`, `spec`, `doc`), artifacts present, mandatory artifacts missing (only for OpenSpec change units) and the artifact fingerprint: `sha256sum proposal.md design.md tasks.md` in that fixed order for a change, or the sorted selected files otherwise. A change unit missing one of the three documents is `INCOMPLETE` in the summary, not a finding.

## Review Strategy: Step-by-Step Plan (No Subagents)

Do not spawn background subagents. Instead of running all unit reviews in parallel at once, create a step-by-step review plan first in `<output-dir>/PLAN.md`, then execute each review step sequentially in session using the cheaper Z.ai GLM model (`zai/glm-5.3-flash#low`) to write unit reports. After all unit reports are written, review and synthesize the summary files using the higher Z.ai GLM model (`zai/glm-5.3#high`).

### Step 1: Create Review Plan (`<output-dir>/PLAN.md`)

Write `<output-dir>/PLAN.md` before inspecting documents:
- Scope, resolved units, identifiers, stage, and artifact fingerprints.
- Ordered review sequence:
  - For each unit:
    1. Security review (`security/<unit>.md`). Model: cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`).
    2. Engineering review (`engineering/<unit>.md`). Model: cheaper Z.ai GLM Flash (`zai/glm-5.3-flash#low`).
  - Final: Summary review, cross-cutting themes, backlog and verdict (`SUMMARY.md`). Model: higher Z.ai GLM (`zai/glm-5.3#high`).

### Step 2: Sequential Step-by-Step Review (Cheaper Model)

Execute unit reviews sequentially in session without dispatching subagents via the `task` tool.
- Apply the cheaper Z.ai GLM model (`zai/glm-5.3-flash#low`).
- Review each unit's documents independently for security and engineering concerns according to the focus areas below.
- Write `<output-dir>/security/<unit>.md` and `<output-dir>/engineering/<unit>.md`. Each follows the `/work-spec` Phase 3 contract:
  - `Status: PASS | CHANGES_REQUESTED | BLOCKED`, the unit identifier and the artifact fingerprint.
  - Findings with stable IDs (`SEC-SPEC-nnn` / `ENG-SPEC-nnn`), severity P0–P3, the affected requirement, decision, task or section, the concrete consequence or attack path, the smallest required document change and the acceptance/verification case.
  - A `Reviewed scope` line and an explicit "no findings in this scope" statement; absence of findings is not proof of completeness.
- Mark unit steps completed in `PLAN.md`.

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

### Step 3: Review Summary Files & Consolidate (Higher Model)

Review all unit reports and write `<output-dir>/SUMMARY.md` using the higher Z.ai GLM model (`zai/glm-5.3#high`):

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

For an active change with P0/P1 findings: revise the documents (tech-lead or manual) and re-run `/review-docs <slug>`; findings are advisory input for Gate 2 and the user decides. For an archived, baseline or ad-hoc document: treat the findings as follow-up work, not a gate. Otherwise recommend `/work-human` or `/work-build` according to stage.
