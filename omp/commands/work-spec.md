---
description: Unify discovery, interview, critique, and OpenSpec specification.
---

# /work-spec <feature-requirements>

Orchestrator: main session. Delegate substantive repository analysis, critique and specification authoring to the `tech-lead` agent through OMP's native `task` tool (`@doc_tier`). The main session owns all user-facing questions and approval gates through the built-in `ask` tool.
Rules: load `rules/core.md`, `rules/planning.md` and `rules/gates.md` before acting.

CRITICAL: Use OMP's built-in `ask` tool for every clarification and gate. Never ask questions as plain chat text.

## PHASE 1 — Interview & Gate 1 (no file changes)

1. **Gap analysis:** dispatch `tech-lead` with a read-only task to inspect relevant code and context; return only material ambiguities, architecture risks, dependencies and failure modes. Scale depth to change risk. The main session synthesizes the result and asks the user; do not ask from the subagent.
2. **Ask:** ask only questions whose answers can change requirements, scope, architecture or acceptance. Prefer one batched set of high-leverage questions with options, a recommendation and "Other". Skip the interview when context is sufficient; never repeat answered questions.
3. **Alignment Summary** in chat:
   - Problem statement and target
   - Confirmed requirements
   - Edge cases and failure handling
   - New package dependencies
   - Out of scope
4. **Gate 1 via `ask`:**
   - `[Recommended] Yes, proceed to synthesize OpenSpec documents.`
   - `Missing details / needs revision.`
   - `Cancel session.`

Proceed only on the first option.

## PHASE 2 — OpenSpec Synthesis (after Gate 1)

Dispatch `tech-lead` to create `openspec/changes/<slug>/` and write the four files below. The main session supplies the confirmed requirements, checks the returned paths and validates the result; do not duplicate the design work in the parent session.

1. **`.openspec.yaml`** — schema marker for the streamlined three-artifact flow:
   ```yaml
   schema: spec-driven
   skip_specs: true
   ```
   `skip_specs: true` is required because this flow records behavior in `proposal.md` instead of capability deltas. If the user explicitly wants OpenSpec delta specs, omit `skip_specs` and add `specs/<capability>/spec.md`. With `skip_specs` there is no active baseline spec, so the archived `proposal.md` is the only durable behavior record — keep every acceptance detail there.

2. **`proposal.md`** — functional PRD:
   - `## Why` — problem and user personas (at least 50 characters).
   - `## What Changes` — journey-level functional requirements; no internal file paths or code extensions.
   - `## Capabilities` — `None (skip_specs enabled)` for this flow, or the capability list when deltas are used.
   - `## Impact` — success metrics, boundaries and dependencies.

3. **`design.md`** — technical architecture:
   - `## Context`
   - `## Goals / Non-Goals`
   - `## Decisions` — domain models, API contracts (payloads, methods, status codes), error matrix, dependencies. Use the Context7 MCP (`resolve-library-id` → `query-docs`) for external API contracts; never send private code or secrets.
   - `## Risks / Trade-offs`

4. **`tasks.md`** — 3–6 atomic tasks:
   ```markdown
   ## 1. <Group>

   - [ ] 1.1 <Task> (files: ...; verify: ...)
   ```
   Every task states its target files and how to verify completion.

If the installed schema differs, run `rtk openspec instructions <artifact> --change <slug> --json` and follow it. Do not read legacy `omp/templates/*`.

Validate before the gate: `rtk openspec validate <slug>`. Fix errors; explain any warning.

## PHASE 3 — Independent design review (before Gate 2)

After synthesis and `openspec validate`, dispatch two fresh read-only reviewers in parallel through the `task` tool: `security-engineer` and `principal-engineer`. Neither wrote the documents. They review `proposal.md`, `design.md` and `tasks.md` against the confirmed requirements, never an implementation.

Compute the artifact fingerprint first: `sha256sum proposal.md design.md tasks.md` inside `openspec/changes/<slug>/`, in that fixed order, and pass the resulting hash to both reviewers. Reports go to `openspec/changes/<slug>/review/security.md` and `openspec/changes/<slug>/review/engineering.md`; each reviewer writes only its own report and includes:

- `Status: PASS | CHANGES_REQUESTED | BLOCKED`, the change slug and the artifact fingerprint.
- Findings with stable IDs (`SEC-SPEC-nnn`, `ENG-SPEC-nnn`), severity P0–P3 (P0/P1 surfaced prominently; advisory), the affected requirement or design section, the concrete consequence or attack path, the smallest suggested design change and the acceptance/verification case.
- A `Reviewed scope` line and an explicit "no findings in this scope" statement when nothing is found; absence of findings is not proof of completeness.

**Security scope:** assets, lower-trust principals and trust boundaries; authentication, authorization and tenant/object scoping; input validation at every entry point; injection sinks (SQL/NoSQL, OS command, template, deserialization, LDAP/XPath, logs); RCE vectors (eval/dynamic code, unsafe deserialization, shell execution, template evaluation, plugin loading, user-controlled file writes); XSS, output encoding and CSP; session, CSRF, cookies and tokens; secrets and cryptography; SSRF and URL fetch; uploads/downloads, path traversal and archive extraction; rate limiting and abuse; error-message leakage; dependency and supply-chain exposure; LLM prompt-injection and tool authorization when applicable.

**Engineering scope:** requirement coverage and the smallest complete design (KISS; no speculative abstraction or unused extension points — YAGNI); module boundaries, dependency direction and SOLID where variation is real; data model, query strategy (N+1, missing indexes, unbounded scans, pagination), transaction boundaries, idempotency and concurrency; durability, migrations/backfill, rollback and backward compatibility; timeouts, retries/backoff, partial failure, recovery and compensation; API contracts and error matrix; observability without sensitive data; testability and verifiable acceptance criteria; task atomicity, order, target files and verify steps; missing non-functional tasks.

**Gate 2 entry rules:**

- Both reviewer reports and their findings are advisory input for the user, never a hard gate.
- `CHANGES_REQUESTED` with any P0/P1 item → offer (do not force) a `tech-lead` revision pass, then re-run only the reviewer that raised the item with a fresh agent. Do not edit the review reports yourself.
- `BLOCKED`, missing or stale review evidence → disclose it at Gate 2 and let the user decide; never fabricate or silently wait.
- Any P0/P1 risk the user explicitly accepts through `ask` is recorded with rationale in `design.md` §Risks / Trade-offs.

## PHASE 4 — Gate 2 (Final Approval)

Display the generated paths under `openspec/changes/<slug>/`, the `tasks.md` checklist, both review statuses, any accepted risks, and every open P2/P3 finding.

**Gate 2 via `ask`:**
- `[Recommended] Approved (specifications locked, ready for /work-build)`
- `Needs revision in documents / task list`
- `Cancel`

**No implementation until the user explicitly selects `Approved`.** `Approved` is always offered; review status is displayed as advisory context alongside it.
