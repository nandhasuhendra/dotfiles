---
description: Unify discovery, Socratic interview, Devil's Advocate critique and OpenSpec specification. Spec → Gate 1 → synthesis → validate → Gate 2.
---

# /work-spec $ARGUMENTS

Orchestrator: this session. Dispatch substantive analysis and synthesis to the `tech-lead` subagent via the `task` tool; keep all user questions and gates here with the built-in `question` tool. Never ask as plain chat text.

## Phase 1 — Interview & Gate 1 (no file writes)

1. Gap analysis: dispatch `tech-lead` (read-only) on the relevant code/context; scale depth to risk. It returns only material ambiguities, architecture risks, dependencies and failure modes.
2. Devil's Advocate critique: on the draft understanding, ask what is wrong — wrong assumptions, missing edge cases, hidden dependencies, cheaper alternatives.
3. Ask (via `question`) only questions whose answers can change requirements, scope, architecture or acceptance. One batched set with options + recommendation; skip when context suffices; never repeat answered questions.
4. Alignment Summary in chat: problem/target, confirmed requirements, edge cases + failure handling, new package dependencies, out of scope.
5. Gate 1 via `question`: `[Recommended] Yes, synthesize OpenSpec documents` / `Missing details — revise` / `Cancel`. Proceed only on the first.

## Phase 2 — Synthesis (after Gate 1)

Dispatch `tech-lead` to create `openspec/changes/<slug>/` (slug: short kebab-case) with exactly:

1. `.openspec.yaml`: `schema: spec-driven` + `skip_specs: true` (behavior lives in `proposal.md`, no capability deltas; only add `specs/<capability>/spec.md` if the user explicitly wants deltas and drop `skip_specs`). With `skip_specs` there is no active baseline spec — the archived `proposal.md` is the only durable behavior record, so keep every acceptance detail there.
2. `proposal.md` — functional, no internal paths/extensions: `## Why` (problem, personas, ≥50 chars), `## What Changes` (journey-level requirements), `## Capabilities` (`None (skip_specs enabled)`), `## Impact` (metrics, boundaries, dependencies).
3. `design.md`: `## Context`, `## Goals / Non-Goals`, `## Decisions` (domain models, API payloads/methods/status codes, error matrix, dependencies — Context7 MCP for external contracts), `## Risks / Trade-offs`.
4. `tasks.md` — 3–6 atomic tasks, each with target files and verify criteria:
   ```markdown
   ## 1. <Group>
   - [ ] 1.1 <Task> (files: ...; verify: ...)
   ```

## Phase 3 — Validate and run the independent design review

Validate: `openspec validate <slug>` (via `rtk openspec` when rtk exists; if the installed schema differs, `openspec instructions <artifact> --change <slug> --json` is authoritative). Fix errors.

Compute the artifact fingerprint: `sha256sum proposal.md design.md tasks.md` inside `openspec/changes/<slug>/`, in that fixed order. Then dispatch two fresh read-only reviewers in one batched `task` call — `security-engineer` and `principal-engineer` — with the confirmed requirements, the three artifacts and the fingerprint. Neither reviewer wrote the documents. Reports go to `openspec/changes/<slug>/review/security.md` and `openspec/changes/<slug>/review/engineering.md`; each reviewer writes only its own report and includes:

- `Status: PASS | CHANGES_REQUESTED | BLOCKED`, the change slug and the artifact fingerprint.
- Findings with stable IDs (`SEC-SPEC-nnn`, `ENG-SPEC-nnn`), severity P0–P3 (P0/P1 block Gate 2), the affected requirement or design section, the concrete consequence or attack path, the smallest required design change and the acceptance/verification case.
- A `Reviewed scope` line and an explicit "no findings in this scope" statement when nothing is found; absence of findings is not proof of completeness.

**Security scope:** assets, lower-trust principals and trust boundaries; authentication, authorization and tenant/object scoping; input validation at every entry point; injection sinks (SQL/NoSQL, OS command, template, deserialization, LDAP/XPath, logs); RCE vectors (eval/dynamic code, unsafe deserialization, shell execution, template evaluation, plugin loading, user-controlled file writes); XSS, output encoding and CSP; session, CSRF, cookies and tokens; secrets and cryptography; SSRF and URL fetch; uploads/downloads, path traversal and archive extraction; rate limiting and abuse; error-message leakage; dependency and supply-chain exposure; LLM prompt-injection and tool authorization when applicable.

**Engineering scope:** requirement coverage and the smallest complete design (KISS; no speculative abstraction or unused extension points — YAGNI); module boundaries, dependency direction and SOLID where variation is real; data model, query strategy (N+1, missing indexes, unbounded scans, pagination), transaction boundaries, idempotency and concurrency; durability, migrations/backfill, rollback and backward compatibility; timeouts, retries/backoff, partial failure, recovery and compensation; API contracts and error matrix; observability without sensitive data; testability and verifiable acceptance criteria; task atomicity, order, target files and verify steps; missing non-functional tasks.

**Gate 2 entry rules:**

- Both reports must exist with `Status: PASS` and a fingerprint matching the current artifacts, or every open item must be P2/P3 and listed in the Gate 2 summary.
- `CHANGES_REQUESTED` with any P0/P1 item → have `tech-lead` revise the documents, then re-run only the reviewer that raised the blocking item with a fresh agent. Repeat until PASS. Do not edit the review reports yourself.
- `BLOCKED`, missing or stale review evidence → do not present Gate 2.
- If the user explicitly accepts a P0/P1 risk via `question`, record the accepted risk and rationale in `design.md` §Risks / Trade-offs, then re-run that reviewer with the updated fingerprint; it may return PASS only after confirming the acceptance is documented and the residual risk is bounded.

## Phase 4 — Gate 2

Show the generated paths under `openspec/changes/<slug>/`, the `tasks.md` checklist, both review statuses, any accepted risks and every open P2/P3 finding.

Gate 2 via `question`: `[Recommended] Approved — specifications locked, ready for /work-build` / `Needs revision` / `Cancel`. **No implementation before the explicit Approved answer.** `Approved` is only offered when the Gate 2 entry rules above hold; a security or engineering review that is missing, stale, `BLOCKED` or `CHANGES_REQUESTED` on a P0/P1 item forbids the gate. Report only the outcome and next action.
