# Active-workflow core rules

Load only after the applicability check in shared `RULES.md`. Read the active prompt and needed rules, not the entire workflow. OMP already supplies the active prompt; do not reopen it.

## Context and effort policy

- Respect the operator-selected model. Never pin models in workflow prompts or silently switch providers.
- Prefer direct inspection/search/tests over delegation unless independent judgment is required. Keep required independent reviews and final QA.
- Delegate one outcome with exact paths, REQ/TC IDs, bounded scope and compact result. Do not ask agents to repeat orchestration or reread unrelated context.
- Child agents use low thinking, no advisor, no nested spawns, and inherit the active route unless the operator configured overrides. Keep per-spawn effort disabled by default.
- Keep one informed primary author across a bundle when practical; role-specific consultation need not recreate documents. Use one independent reviewer for each of the two pre-build bundles and specialists only for material risk. Parallel agents are not automatically cheaper.
- Load tools/skills/docs only when relevant: Codegraph and source/LSP for nontrivial impact; Context7 for external documentation questions below; actual Playwright for browser behavior; Ponytail for implementation; the applicable Antislop variant for code/prose/UI/accessibility/responsive work. Read the matching skill before using it; never trigger unrelated setup or audits to fill a checklist.
- Reuse paths, IDs, digests and existing evidence instead of copying full documents into handoffs. Read full authoritative content needed for the decision; supporting context is on demand.
- For unchanged artifacts already in context, verify identity/freshness without rereading their bodies. New agents must read the specific authoritative inputs needed for their own task.
- Respect free-model/operator routing; independence means separate author, QA and reviewer runs, not mandatory model diversity. Unknown usage stays unknown. Report unavailable required dispatch/model access as BLOCKED; never silently switch to paid routes or persist configuration.

## Scope and risk

Classify work as focused (localized, low-risk, behavior-preserving), full (new behavior, cross-module, migration, uncertain impact), or security-sensitive. If unsure, use full. Focused reduces exploration and verbosity, never approval, review, QA or verification gates. Escalate when scope or risk expands; invalidate affected approvals.

## Smallest complete change

- Solve the stated requirement at the smallest scope that fully satisfies it. Complexity is justified only by an approved requirement or observed evidence, never by hypothetical future needs.
- Reuse existing patterns, files, dependencies and commands. Add a module, dependency, abstraction, configuration option, feature flag, agent or command only when the current structure cannot carry the change.
- Do not add speculative extension points, duplicate policy, dead code, compatibility shims or unused configurability. Remove what the change makes obsolete.
- Over-engineering is a review finding: a reviewer may require removal even when behavior and tests pass, especially when a simpler equivalent exists.
- This applies to code and to workflow artifacts (`RULES.md`, `rules/`, `agents/`, `commands/`). Keep one source of truth and reference policy instead of restating it.

## Stop, escalate and retry policy

Stop exploration and move forward when the current decision has enough source-backed evidence to satisfy its completion condition; do not keep searching for theoretical completeness.

| Stage | Stop when | Escalate or reopen when |
|---|---|---|
| Interview | Current-state evidence, goals, affected users/journeys, constraints, non-goals, dependencies and measurable positive/negative acceptance outcomes are aligned and material decisions are resolved. | New evidence reveals a material behavior, business rule, compatibility or data/security decision not already settled. |
| Repository exploration | Relevant entry points, callers, tests, contracts and risks are mapped for the proposed change. | Evidence reveals broader coupling, hidden consumers, data migration, security exposure or uncertain compatibility. |
| Design | The approved outcome has a feasible approach, key trade-offs, dependencies and failure/rollback handling. | An unresolved alternative could materially change correctness, risk, cost or scope. |
| Implementation | Every approved task is complete and deviations are recorded. | Scope/acceptance changes, a task cannot be completed safely, or new material risk appears. Stop and return to the relevant approval gate. |
| Review | The assigned manifest was inspected, findings are evidence-backed, and all blocking findings are resolved. | Inputs changed, evidence is missing, or a finding cannot be resolved from available source. |
| Verification | Every required scenario has a current result and all required independent reviews/checks pass for the current source identity. | Any required scenario is FAIL, BLOCKED or NOT_RUN, or source/artifact identity changes. |
| Retry | A concrete failure has a likely cause and the retry targets that cause or invalidated evidence. | Repeated attempts produce no new evidence; report the blocker rather than looping or silently increasing effort. |

- Know which decision each call resolves and what evidence could change the next action; keep that rationale internal unless it helps the human. Do not add narration before every tool.
- Use one targeted correction cycle for a bounded finding before broadening exploration or effort. Increase effort/model only when the remaining uncertainty is material; the operator controls model selection.
- Re-run only checks and reviews invalidated by changed inputs, plus any dependent checks. Never reuse stale evidence or treat skipped work as PASS.
- Do not optimize for a fixed number of calls. Stop when the gate's evidence requirements are met, not when a token budget is exhausted; if limits block required work, mark BLOCKED and hand back the exact next action.


## Communication and artifacts

- Read the Caveman skill for routine communication; reuse it in the same session. It does not govern document prose.
- Keep handoffs/status concise and preserve facts, IDs, paths, numbers, errors, uncertainty and evidence. Never trade away safety or correctness.
- Durable artifacts (PRDs, Tech Docs, QA plans, tasks, code comments, commits and PRs) use clear, professional, self-contained prose. Remove filler, not rationale or meaning.
- Use full sentences for security warnings, irreversible actions, confusing situations, ordered steps and approval questions.

## Load and scope

- Apply shared `RULES.md`'s opt-in boundary before loading this file. During an activated operation resolve shared rules under `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`; required project `.omp/RULES.md` supplements, never replaces, those rules. Stop if a required policy cannot be read.
- Read repository `AGENTS.md`, relevant source and existing human documentation before proposing changes. Inspect OpenSpec config/schema during implementation preparation, after human planning approval.
- Keep one change in `openspec/changes/<slug>/`. Use a kebab-case slug; never overwrite an existing change to start another.
- Record route in `interview.md`: product (new/improved user-facing behavior), engineering (internal technical outcome), or mixed. Ask only when business intent cannot be established from the request.
- No application code, production configuration, migrations or implementation tests before reviewed `execution` approval. Reading source and running existing checks are allowed.

## Universal tool routing

- Prefer specialized file read/search/edit tools over shell equivalents. Every shell tool invocation MUST go through RTK: supported `rtk <subcommand>` first; `rtk proxy <command> [args]` when unsupported, required flags are rejected or compression would hide needed detail; `rtk run '<shell command>'` for pipelines or compound shell syntax. Inspect installed help rather than guessing support.
- Preserve actual exit status and full failure evidence; retain raw logs or rerunnable raw commands. If RTK is unavailable, shell execution is BLOCKED; never bypass it with a native command. Compression and `rtk gain` output are not verification or total model-token benchmarks.
- Use Context7 for documentation questions about external libraries, frameworks, SDKs, APIs, CLI tools or cloud services. Resolve the library ID, then query the specific relevant topic; an exact supplied Context7 ID permits querying directly. Match installed versions when supported and record returned sources/version limitations. Never send private code or secrets.
- Reuse current applicable Context7 results rather than repeating queries. If retrieval is unavailable, use authoritative version-relevant documentation with a disclosed limitation; block material decisions that remain unresolved. Record actual invocations/results or a brief N/A reason, never tool name-dropping.

## Readability and evidence

- Prefer short headings, bullets and compact tables; paragraphs at most three sentences. No boilerplate sections with invented content.
- Keep stable `REQ-001` and `TC-001` IDs across artifacts. Each scenario states preconditions, action and observable expected outcome; link tasks and evidence rather than copying paragraphs.
- QA covers positive, negative, boundary, permissions/security, compatibility and affected-feature regressions; add concurrency, performance or migration cases when applicable. Mark N/A with a reason, not silent omissions.
- Report scenario outcomes as PASS, FAIL, BLOCKED or NOT_RUN. Record actual command, exit code and result; browser checks include steps and observed state. Tests alone do not replace a smoke run of the changed path.
- Distinguish observed facts, assumptions and risks. Never weaken tests to match a defect, fabricate delegation/results, or claim existing features cannot regress.
- Status output: `Gate | Evidence/freshness | Blocker | Next command`. Report unavailable dependencies and unrun scenarios honestly.
- Record review-ready separately from explicit human acceptance. No PR, deployment or archive is required to preview or review results. Use existing `verification.md` for correction-cycle accounting; see verification rules. Do not ask duplicate approvals or questions solely to create a metric.
- Never delete unrelated work, run destructive commands, merge, release, deploy or archive without explicit human authorization.

