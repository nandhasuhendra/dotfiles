---
description: Generate the human planning bundle (PRD, Tech Doc, Task Breakdown) from an approved OpenSpec change.
---

# /work-human <slug>

Role: Principal Product Manager and Lead Software Architect (`@doc_tier`).
Rules: load `rules/core.md`, `rules/planning.md` and `rules/gates.md` before acting.

Purpose: turn an approved `/work-spec` change into a readable human planning bundle. This command is documentation-only. It never edits application code, installs packages, or rewrites the OpenSpec artifacts.

## Preconditions (fail closed, no file changes)

1. Resolve the change slug from `$1`. If omitted and exactly one active change exists under `openspec/changes/`, use it; otherwise stop and ask the user to name one.
2. Require all four OpenSpec artifacts: `openspec/changes/<slug>/.openspec.yaml`, `proposal.md`, `design.md` and `tasks.md`. If any is missing, stop and tell the user to run `/work-spec <feature>` (or `/work-resume <slug>`).
3. Run `rtk proxy openspec validate <slug>`. If validation fails, stop and report the errors; do not generate human documents from an invalid change.
4. Confirm the `/work-spec` Gate 2 decision through OMP's built-in `ask`. Gate confirmations are session-local, so never infer approval from files or from this command being invoked.
   - `[Recommended] Yes — Gate 2 was Approved for this change.`
   - `No — stop; run /work-spec first.`
   - `Not sure — stop; run /work-status.`

   Continue only on the first option. This precondition is the only ordering guard: `/work-human` is runnable only after a completed, approved `/work-spec`.
5. Read the installed templates from `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/templates/`: `PRD.md`, `TECH-DOC.md` and `HUMAN-TASK-BREAKDOWN.md`. Stop if they are unreadable.

## Phase 1 — Reuse the approved change (read-only)

- Read `proposal.md`, `design.md` and `tasks.md`; treat them as the source of truth.
- Inspect existing source, screenshots, callers or documentation only where the templates need evidence. Use the Context7 MCP for external contracts and never send private code or secrets.
- Reuse settled decisions. Do not re-interview or restate answered questions. Record non-blocking gaps as open decisions. If a missing fact would change approved scope or design, stop and direct the user back to `/work-spec`; do not resolve it by silently changing the approved artifacts.
- Build one traceability set and keep it identical across all three documents: stable `REQ-*`/`FR-*` IDs derived from the proposal, `US-*` journeys, the Tech Doc's `CT-*`/`Q-*`/`EV-*` IDs, and the OpenSpec task numbers.

## Phase 2 — Write the bundle

Create `openspec/changes/<slug>/human/` and generate exactly these files from the installed templates:

1. `PRD.md` from `templates/PRD.md`
2. `TECH-DOC.md` from `templates/TECH-DOC.md`
3. `HUMAN-TASK-BREAKDOWN.md` from `templates/HUMAN-TASK-BREAKDOWN.md`

Template fidelity rules:

- Preserve each template's frontmatter fields and heading structure. Fill `title`, `created`, `updated`, `status: draft` and `tags`; replace or delete every authoring-guidance paragraph with real content.
- Replace every `{{placeholder}}` and angle-bracket placeholder. Use `TBD` only for genuinely unknown names or owners; never invent people, metrics, customers, incidents or verification results.
- Mark inapplicable sections `N/A — reason` instead of inventing stack details. Keep template sections that apply to this change.
- Fix the template's gate link (`../rules/gates.md`) so it is not a broken relative link. Reference the installed workflow policy in plain text, or link a real project path when one exists.
- Templates may mention retired `human-planning` or `execution` approval bundles, `test-plan.md` or `verification.md`. Do not invent those gates or files. Rewrite such references to the current two-gate protocol and only link artifacts that actually exist; describe future evidence paths as future.
- Link the bundle internally with relative paths: the PRD links `TECH-DOC.md` and `HUMAN-TASK-BREAKDOWN.md`; the Tech Doc links `PRD.md` and `HUMAN-TASK-BREAKDOWN.md`; the Task Breakdown links both.
- Do not modify `proposal.md`, `design.md`, `tasks.md` or any application file. Do not widen the approved scope.

Document-specific mapping:

- **PRD.md:** derive the executive summary, personas, journeys and requirements from `proposal.md`; use `design.md` only for dependencies and technical boundaries. Keep requirement IDs stable and functional; no internal file paths or code extensions in requirement statements.
- **TECH-DOC.md:** derive context, goals/non-goals, decisions, contracts, error matrix, dependencies and risks from `design.md`. Keep the template's contract-first structure. Mark data, events, backend, frontend or other sections `N/A — reason` when the approved design does not cover them.
- **HUMAN-TASK-BREAKDOWN.md:** derive milestones from the OpenSpec `tasks.md` and the design contracts. Preserve one BE and one FE task per PRD journey when the template requires journey pairs, and link each task to its `REQ-*`, `US-*`, `CT-*` and OpenSpec task IDs. Keep progress and evidence out of the plan; reference the change verification record instead.

## Phase 3 — Verify and hand off

1. Run `rtk proxy openspec validate <slug>` again. The OpenSpec change must remain valid.
2. Scan the three files for template residue (`{{`, `Authoring guidance:`, `<relative link>`, `<module>`, `<Name or TBD`) and replace it before finishing.
3. Verify the internal relative links resolve within `human/`.
4. Show the generated paths, a compact REQ-to-task coverage summary and any recorded open decisions.
5. State clearly that these are human-review documents, not approval or verification evidence. Gate 2 remains the `/work-build` approval; `/work-human` adds no gate and does not authorize implementation, archive, PR or release.
