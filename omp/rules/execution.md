# Execution-stage rules

Load with `core.md` for implementation. Load `verification.md` for verification, security review or archive.

## Dependency use
- OpenSpec owns the change lifecycle and schema. Inspect installed help/config/schema; never guess commands or bypass validation.
- Ponytail: read its installed skill before implementation; reuse unchanged guidance already read in the same session, but a fresh child must read it itself. Choose the smallest complete solution while preserving validation, security, accessibility and error handling.
- Codegraph: inspect affected callers/interfaces/regression surface when relevant; confirm findings in source and refresh stale indexes.
- Context7: follow core's resolve/query, version/source, privacy and evidence-reuse policy for external documentation questions. Block material unresolved decisions.
- Playwright: execute changed browser flows, error states, keyboard access and relevant viewports. Browser work without executable Playwright is BLOCKED, never simulated PASS.
- RTK: follow core's universal shell-routing and fallback policy in every stage. Preserve exit status and full failure evidence; compression is not verification.
- Antislop: read only the matching code/prose/UI/accessibility/responsive guidance. Do not start unrelated setup, asset searches or audits for non-UI work.

## Subagent implementation and main-agent review

- Implementation tasks are delegated to `software-engineer` subagents running on the configured cheaper execution tier (`@execution_tier`).
- The main agent (orchestrator running the primary model) MUST directly review the subagent's implementation before proceeding to verification or asking for human gate review:
  1. Inspect changed files and git diff for correctness, error handling, and scope containment.
  2. Enforce Ponytail principles (smallest complete change, no dead code or unasked-for abstraction).
  3. Confirm schema integrity via `rtk proxy openspec validate <slug>`.
  4. If defects, compilation/test errors, or missed requirements occur, direct the subagent to repair them immediately.
- Only after main-agent validation passes does the workflow advance to independent verification (`/work-verify`) and subsequent human gate presentation.

## Implementation code readability

- Write implementation code for human readers. Do not compress statements or blocks merely to reduce lines or tokens.
- Follow the repository's formatter, EditorConfig and surrounding language conventions for indentation, spaces, tabs, line endings and line width. Do not mix tabs and spaces for indentation; preserve syntax-required whitespace.
- Use consistent spacing around operators, after separators and within expressions according to the language's style. Remove trailing whitespace and end text files with a newline.
- Separate logical steps and adjacent declarations with blank lines where they make the structure clearer. Keep related statements together; do not insert an empty line after every statement.
- Put separate statements on separate lines. Expand dense conditionals, nested expressions, long argument lists and chained calls into readable multiline blocks using the existing formatter's layout.
- Keep nesting and block boundaries visually clear through consistent indentation. Prefer explicit, readable control flow over clever one-liners.
- Check changed code for readability before handoff. Use existing formatting checks at a stable checkpoint; limit formatting changes to the touched code and do not add a formatter solely for this rule.

## Evidence
Record actual invocations and outcomes, not just tool names. Mark inapplicable tools N/A with a reason. Keep raw logs or rerunnable commands for gate checks. Do not install dependencies, alter global settings, enable unsafe browser flags or send repository data externally without authorization.

## Stable-checkpoint feedback

- Run the narrow compiler, contract, unit or changed-path smoke check once an owned slice and its required dependencies are stable; do not wait for every task to finish to discover cheap failures.
- Do not run checks against files another agent is actively mutating. One integration owner coordinates shared surfaces; wait for a stable checkpoint or use an isolated source snapshot and record its identity.
- Preserve failures, fix the root cause within approved scope, and repeat only invalidated/dependent checks. Retain a small behavioral regression test for uncertain nontrivial logic, not prompt-text or wiring assertions.
- Author checks are development feedback, never independent QA/review. Final integration checks and separate current-source QA/reviewer verdicts remain required.

## Context efficiency
- Read complete authoritative inputs required for the current decision; scope source exploration to relevant callers, tests, fixtures, configuration and exports, then expand when evidence warrants it.
- Handoffs should carry slug, route/effort, paths and digests, REQ/TC IDs, decisions, blockers and next action—not transcript dumps or repeated full documents.
- Reuse unchanged evidence only after checking identity/freshness. A digest proves identity, not comprehension; independent reviewers must inspect authoritative inputs themselves.
- Scope a re-review or re-verification to the delta: the changed artifact, the prior findings and the inputs they depend on. A first review still reads every authoritative input it is bound to.
- Batch independent scoped reads/searches when possible and do not reread unchanged content already in context. New agents must still read the authoritative inputs needed for their own decisions.
- Record available usage and correction-cycle evidence in existing `verification.md` under verification rules. RTK output reduction is not a model-token or productivity benchmark.
