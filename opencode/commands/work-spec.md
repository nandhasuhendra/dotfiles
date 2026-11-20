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

## Phase 3 — Gate 2

Validate: `openspec validate <slug>` (via `rtk openspec` when rtk exists; if the installed schema differs, `openspec instructions <artifact> --change <slug> --json` is authoritative). Fix errors. Show the generated paths and the `tasks.md` checklist.

Gate 2 via `question`: `[Recommended] Approved — specifications locked, ready for /work-build` / `Needs revision` / `Cancel`. **No implementation before the explicit Approved answer.** Report only the outcome and next action.
