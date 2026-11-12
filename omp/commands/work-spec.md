---
description: Unify discovery, interview, critique, and OpenSpec specification.
---

# /work-spec <feature-requirements>

Role: Principal Product Manager and Lead Software Architect (`@doc_tier`).
Rules: load `rules/core.md`, `rules/planning.md` and `rules/gates.md` before acting.

CRITICAL: Use OMP's built-in `ask` tool for every clarification and gate. Never ask questions as plain chat text.

## PHASE 1 — Interview & Gate 1 (no file changes)

1. **Gap analysis:** inspect relevant code and context; identify only material ambiguities, architecture risks, dependencies and failure modes. Scale depth to change risk.
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

Create `openspec/changes/<slug>/` and write four files:

1. **`.openspec.yaml`** — schema marker for the streamlined three-artifact flow:
   ```yaml
   schema: spec-driven
   skip_specs: true
   ```
   `skip_specs: true` is required because this flow records behavior in `proposal.md` instead of capability deltas. If the user explicitly wants OpenSpec delta specs, omit `skip_specs` and add `specs/<capability>/spec.md`.

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

If the installed schema differs, run `rtk proxy openspec instructions <artifact> --change <slug> --json` and follow it. Do not read legacy `omp/templates/*`.

Validate before the gate: `rtk proxy openspec validate <slug>`. Fix errors; explain any warning.

## PHASE 3 — Gate 2 (Final Approval)

Display the generated paths under `openspec/changes/<slug>/` and the `tasks.md` checklist.

**Gate 2 via `ask`:**
- `[Recommended] Approved (specifications locked, ready for /work-build)`
- `Needs revision in documents / task list`
- `Cancel`

**No implementation until the user explicitly selects `Approved`.**
