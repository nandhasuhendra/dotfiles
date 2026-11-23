---
name: work-spec
description: Discover requirements, interview, create and independently review OpenSpec artifacts, then request explicit Gate 1 and Gate 2 approvals before implementation.
---

# /work-spec <feature requirements>

The primary session is the orchestrator. Load the global workflow rules and only the minimum relevant project context. Do not modify application code. Always use the built-in `ask_question` tool whenever asking the user any clarifying question or requesting Gate 1 / Gate 2 decisions.

## Phase 1 — discovery and Gate 1

1. Inspect relevant code/docs narrowly. Delegate substantial read-only repository analysis to a fresh `tech-lead` subagent if available. Use the built-in `ask_question` tool to ask the user only questions whose answers change requirements, architecture, scope, or acceptance.
2. Present an Alignment Summary: problem/personas, confirmed requirements, edge cases/failure handling, dependencies, out of scope, risks.
3. Present Gate 1 options using the built-in `ask_question` tool: `(Recommended) Proceed to synthesize`, `Revise / missing details`, `Cancel`. STOP. Do not create artifacts until the user explicitly chooses proceed in this conversation.

## Phase 2 — OpenSpec synthesis

After Gate 1 approval, create `openspec/changes/<slug>/` with:
- `.openspec.yaml`: `schema: spec-driven` and `skip_specs: true` for the streamlined flow.
- `proposal.md`: Why, What Changes, Capabilities, Impact.
- `design.md`: Context, Goals / Non-Goals, Decisions, Risks / Trade-offs.
- `tasks.md`: 3–6 sequential atomic tasks; every task names target files and verification.
Use OpenSpec instructions/CLI if installed; validate with `openspec validate <slug>`. Use Context7 (resolve-library-id then query-docs) for external API/library contracts; never send private code or secrets.

## Phase 3 — independent design review

1. Compute a deterministic fingerprint of `.openspec.yaml`, `proposal.md`, `design.md`, `tasks.md` (sorted path + SHA-256).
2. Dispatch fresh `security-engineer` and `principal-engineer` subagents independently. Neither may author the spec; do not share the other's findings. Require each report under `review/security.md` or `review/engineering.md`, with status PASS / CHANGES_REQUESTED / BLOCKED, fingerprint, scope, stable finding IDs, P0–P3, concrete consequence, smallest fix, and acceptance test.
3. If parallel isolated subagents are unavailable, disclose this and mark the gate BLOCKED rather than pretending independence.
4. Both reports are advisory input for the user; surface P0/P1 prominently and record user-accepted risks in `design.md`. Gate 2 is decided by the user through `ask_question`. Revise and re-review with a fresh agent when the user wants a revision pass.

## Phase 4 — Gate 2

Show artifact paths, task checklist, both review statuses, accepted risks, and open P2/P3 items. Use the built-in `ask_question` tool to ask the user to choose `Approved`, `Needs revision`, or `Cancel`. STOP. Never implement in this skill. Approval applies only to this conversation and current artifact fingerprint.
