# Gated engineering workflow

## Load and scope

- Commands and agents must read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Project rules may strengthen, not silently bypass, these gates.
- Read repository `AGENTS.md`, OpenSpec config, existing specs, and relevant source before proposing changes.
- Keep one change in `openspec/changes/<slug>/`. Use a kebab-case slug; never overwrite an existing change to start another.
- Record route in `interview.md`: product (new/improved user-facing behavior), engineering (internal technical outcome), or mixed. Ask only when business intent cannot be established from the request.
- No application code, production configuration, migrations, or implementation tests before the implementation gate. Reading source and running existing checks are allowed.

## Dependencies

| Dependency | Required use | Unavailable or unsuitable |
| --- | --- | --- |
| OpenSpec | Own change lifecycle, proposal, delta specs, design/tasks as required by installed schema, validation, archive. Inspect `openspec --help`, project config and artifact instructions first. | Block change creation/transitions until working; do not invent a replacement CLI. |
| Ponytail | Read the installed skill. Smallest complete solution; preserve validation, security, accessibility and error handling. Map callers, tests, fixtures, config and exports. | Block implementation until available. |
| Codegraph | Inspect installed help/tools; analyze affected callers, interfaces and regression surface before design, QA and implementation. Confirm graph findings in source; refresh stale indexes. | Record the failure and use source/reference tools with an explicit coverage limit; never claim a graph analysis ran. |
| Playwright | Exercise changed browser flows, error states, keyboard access and relevant viewport sizes; record actual outcomes and evidence. | Non-browser work: N/A with reason. Browser work: BLOCKED until executable, not a simulated PASS. |
| Context7 | Resolve the library ID, then query version-relevant docs for library/API/CLI decisions. Record source/version; send no private code or secrets. | Use authoritative version-matched docs with a recorded limitation; block decisions still unverified. |
| rtk-ai (`rtk`) | Wrap every model-facing shell command: specialized subcommand, `rtk proxy` or `rtk run`. Use installed help rather than guessing. | Run the original command, record the fallback and preserve exit status/full failure evidence. Compression is not verification. |

- Availability means a successful invocation, not merely a binary on PATH. Record versions, applicable tools and limitations in `interview.md`.
- Keep uncompressed logs or rerunnable raw commands and exit codes for verification. Never hide failing output behind RTK filtering.
- Do not install dependencies, change global settings, enable unsafe browser flags or send repository data externally without appropriate authorization.

### Use by stage

| Stage | Required tools | Evidence to record |
| --- | --- | --- |
| Interview | OpenSpec, rtk | `openspec --version`, schema/help inspected, actual RTK-wrapped commands |
| Spec / design | OpenSpec, Codegraph, Context7, Ponytail, rtk | schema read, affected callers/interfaces, resolved library/version, smallest-solution note, raw commands |
| QA plan | OpenSpec, Codegraph, Playwright when browser, rtk | regression surface, planned browser flows, supported test commands |
| Implement | Ponytail, Codegraph, Context7, rtk | smallest complete change, source-confirmed impact, version-specific API decisions, raw commands |
| Verify | OpenSpec, Playwright when browser, rtk | validation result, observed browser evidence, raw exit codes/logs |
| Security | Codegraph, Context7, Playwright when applicable, rtk | abuse paths, version-behavior checks, browser evidence, raw commands |

Tools are required only when their concern applies. Record N/A with a reason instead of staying silent.

## Shell commands and tool evidence

- Run every model-facing shell command through `rtk`:
  - `rtk <specialized>` when the subcommand exists, such as `rtk git status`, `rtk grep`, `rtk test`, `rtk playwright`;
  - `rtk proxy <command> [args]` when the specialized route rejects required flags, hides needed failure detail, or the command is unsupported;
  - `rtk run '<shell command>'` for pipelines, redirection or compound shell syntax.
- Prefer the specialized route when it preserves the output you need. State why you fell back to `proxy` or `run` when the distinction matters.
- Do not call the underlying tool directly when a supported RTK route exists. File read/search/edit tools remain preferred over shell; this rule covers shell execution.
- Internal script plumbing that produces no agent-facing output (tests, PID checks, file moves) may run natively. Keep its failure behavior explicit and do not present it as RTK-covered.
- Preserve exact exit status and failure evidence. For gates, use `rtk proxy` or save the full raw output; RTK compression and summaries are convenience, never verification proof. Never hide a failing command behind a filter.
- If `rtk` is unavailable or cannot run a command safely, run the original command and record the fallback and reason. Never claim RTK was used when it was not.
- `rtk gain -p` may report adoption or savings at status/verification; it is not correctness evidence.
- In the handoff `Evidence` line, name each dependency actually invoked with its result, or mark it N/A with a reason: OpenSpec command, Ponytail skill read, Codegraph tool, Context7 library/version, Playwright run, RTK wrapper. Naming a tool without an invocation is not use.

## Artifacts and ownership

| Artifact | Owner | Minimum content |
| --- | --- | --- |
| `interview.md` | interviewer | Route, current/desired behavior, users, goals, constraints, non-goals, facts, assumptions, blocking questions, dependency readiness. |
| `prd.md` | product-manager | Product/mixed route: business outcome, flows, rules, stable REQ IDs, measurable acceptance, success measures. |
| `design.md` | tech-lead | Engineering/mixed route, or product requiring technical decisions: current/proposed behavior, REQ IDs, impact, alternatives, contracts, failure/security risks, rollout/rollback. |
| OpenSpec artifacts | product-manager + tech-lead | Installed schema's proposal and delta specs reflecting approved intent; design/tasks when required. Link REQ IDs; do not maintain competing requirements. |
| `test-plan.md` | qa-engineer | TC-to-REQ coverage, Given/When/Then, priority, layer, fixtures, expected results, affected existing-feature regression, manual gaps. |
| `tasks.md` | tech-lead | Ordered implementation and test tasks linked to REQ/TC IDs, affected files, dependencies, rollout/rollback. |
| `review.md` | reviewer + security-engineer | Append independent gate/security records: target, input path/digest manifest, PASS/CHANGES_REQUESTED/BLOCKED, file/line findings, risks, tool-use evidence or N/A reasons. Security records include red-team attack paths and blue-team mitigations. |
| `approvals.md` | orchestrator | Append-only human decisions binding exact artifact/input digests; never write approval on a human's behalf. |
| `verification.md` | qa-engineer + reviewer | Per TC/REQ result and real command/browser evidence, dependency invocations/results, implementation identity, regressions, review findings, remaining risks. |

- Product route requires PRD; engineering route requires design; mixed requires both. Schema-required design is still required on product work. Human approval covers the entire spec bundle, not just the PRD title.
- Questions affecting scope, expected behavior, compatibility, security or data integrity block approval. Explicitly accepted nonblocking assumptions remain visible.
- Authors may use their role instructions directly if dispatch is unavailable and disclose it. Gate review and final QA verification require independent agent runs with full context; no self-review fallback. If dispatch is unavailable, mark BLOCKED.

## Document templates

| Output | Template | Author |
| --- | --- | --- |
| `prd.md` | `PRD.md` | product-manager |
| `design.md` | `TECH-DOC.md` | tech-lead |
| `test-plan.md` | `QA-TEST-CASES.md` | qa-engineer |
| `tasks.md` | `TASK-BREAKDOWN.md` | tech-lead |

- Before authoring, read the matching project `.omp/templates/<file>` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/templates/<file>`. Stop if neither exists; pass the resolved path and template content to dispatched authors.
- Templates guide document content, not business policy. Fill them from confirmed inputs and source evidence; preserve IDs, explain applicable N/A cases and remove example rows/unresolved template tokens before review. Unknown material decisions stay explicit blockers, never invented defaults.
- For OpenSpec-owned design/tasks, installed schema instructions take precedence over template headings, metadata and checkbox syntax. Adapt the content checklist to that schema; do not introduce a second lifecycle or requirement set.
- Keep generated documents concise, link existing contracts rather than duplicating them, and add only known owners/dates and real references. Draft metadata or a filled checklist never counts as approval or execution.
- Template changes do not silently regenerate approved documents. Rewriting an existing artifact follows the normal digest/review/reapproval rules.

## Gates

Every transition rechecks all upstream evidence. Missing, stale, FAIL, BLOCKED or NOT_RUN evidence never means PASS. Review PASS is not human approval. OpenSpec readiness is not human approval either.

| Next action | Required evidence |
| --- | --- |
| Write PRD/design (`work-spec`) | Interview complete, no blocking questions, independent interview review PASS, human interview approval. |
| Write QA scenarios (`work-qa`) | Route-required spec bundle complete, independent spec review PASS, explicit human spec approval. |
| Plan tasks (`work-plan`) | Every REQ covered by QA scenarios, independent test-plan review PASS, explicit human test-plan approval. |
| Implement (`work-implement`) | Fresh interview/spec/test-plan approvals, complete tasks, independent tasks review PASS, human tasks approval binding the full planning bundle, successful OpenSpec validation. |
| Verify (`work-verify`) | Implementation tasks complete; approved scope preserved; current source identity, test changes and runnable checks available. |
| Archive (`work-archive`) | All required scenarios PASS, no unresolved review defects, OpenSpec validation PASS, independent QA and reviewer PASS for current source, explicit human archive authorization. Merge/release requires its own authorization. |

- Each stage command runs its required independent review, repairs findings within approved scope, then presents one checkpoint. The human does not need to run a separate review command.
- Stop at every human approval boundary. Do not chain past a pending decision, infer approval from silence, or treat a generic "continue" as approval of undisclosed content.
- Material scope changes return to interview/spec. Changed QA expectations return to QA approval. Repair code within approved scope, then repeat affected verification.
- Spec review requires a separate `security-engineer` red-team/blue-team assessment of the same input manifest before the reviewer can PASS. QA must cover its threat scenarios; subsequent gate reviews check that coverage and mitigation tasks remain intact.
- Final verification requires a fresh independent security-engineer PASS bound to the actual source and approved planning manifests, in addition to QA/reviewer PASS. Missing dispatch, stale security evidence or unresolved security findings blocks the gate. Record security results in `review.md` and reference them from `verification.md`; no extra human approval target.

## Human checkpoints

Every stage ends with exactly one checkpoint, not a chain of questions. Keep it scannable:

```text
Stage: <stage> | review: <PASS/CHANGES_REQUESTED/BLOCKED>
Artifacts: <paths or "none">
Reviewed: <what changed since the last decision>
Open questions: <none or blocking list>
Decision: approve | approve stop | reject: <reason> | revisit: <question/stage> | pause
```

- `approve`: record the decision with the approval protocol, then continue to the next stage in the same turn.
- `approve stop`: record the decision and stop. The next stage remains available.
- `reject: <reason>`: record the rejection without approval, route to the responsible author and stop.
- `revisit: <question/stage>`: reopen that stage; changed inputs invalidate dependent approvals/reviews/tasks/verification.
- `pause`: record nothing and point to `/work-resume <slug>`.
- One explicit reply is enough. Do not ask for the same decision twice; do not make the human re-run review after a PASS unless inputs changed.
- Show artifact paths, a one-line scope/risk summary, review findings and the manifest identity before asking. Invocation, silence, "continue" or an earlier approval is not a decision.
- `work-review` performs the independent review and presents this checkpoint. `work-approve` resumes a pending decision or records one supplied after a review.

## Agent handoffs

- Each author reads its gate inputs, writes only its owned artifacts and returns a handoff block to the orchestrator. The orchestrator, not a subagent, presents the human checkpoint and records decisions.
- Required handoff block:

```text
Gate: <stage> | <PASS/CHANGES_REQUESTED/BLOCKED>
Artifacts: <paths>
Evidence: <actual commands/tools/results, or N/A reason for each required dependency>
Open questions: <none or blocking list>
Next: <one command or action>
```

- Keep handoffs factual: actual commands, observed results, limitations and unresolved blockers. Never claim approval, verification or delegation that did not happen.
- Do not repeat information already in an approved artifact; link it. If an upstream contract changes, state which downstream records are invalidated.

## Approval and freshness protocol

These are agent-enforced gates, not a runtime access-control mechanism. There is no `scripts/workflow_gate.py`; do not call it or claim automated enforcement.

1. Build a sorted manifest of relative artifact paths and SHA-256 file digests. Use real hashing tools, such as `sha256sum` on Linux or `shasum -a 256` on macOS. Never invent hashes.
2. Bind interview approval to `interview.md`; spec approval to interview plus all route/schema specification inputs (including proposal and every delta spec); test-plan approval to those inputs plus `test-plan.md`; tasks approval to all previous inputs plus `tasks.md`. Include OpenSpec config/schema inputs used by the change. Exclude the mutable approval/review/evidence ledgers themselves.
3. Reviewer records PASS against the same input manifest for that gate. Show the human artifact paths, review findings, short scope/risk summary and manifest before asking approval.
4. After an explicit human decision, recompute the manifest. If unchanged, append target, UTC timestamp, human decision reference/quote, manifest and matching review record to `approvals.md`. If changed during the decision, ask again. Never modify historical decisions.
5. Before proceeding or resuming, re-enumerate files and recompute every upstream manifest. Changed bytes, missing files or new specification inputs invalidate that gate and all dependent approvals/reviews/tasks/verification. Treat prior records as historical, not current authority.
6. Freeze approved `tasks.md` content. Track execution completion and evidence separately in `verification.md` so checkbox edits do not silently invalidate task approval. Reconcile OpenSpec task checkboxes only after verification and human archive authorization; record that completion-only reconciliation and rerun validation. Any task wording/scope change requires renewed task review/approval.
7. Bind final verification to current source: record HEAD plus a digest manifest of changed tracked and relevant untracked files (including deletions), or a full relevant-source manifest outside Git. HEAD alone does not identify a dirty worktree. Source/test/config changes invalidate verification; rerun affected checks and independent review.

## Readability and evidence

- Prefer short headings, bullets and compact tables; paragraphs at most three sentences. No boilerplate sections with invented content.
- Keep stable `REQ-001` and `TC-001` IDs across artifacts. Each scenario states preconditions, action and observable expected outcome; link tasks and evidence rather than copying paragraphs.
- QA covers positive, negative, boundary, permissions/security, compatibility and affected-feature regressions; add concurrency, performance or migration cases when applicable. Mark N/A with a reason, not silent omissions.
- Report scenario outcomes as PASS, FAIL, BLOCKED or NOT_RUN. Record actual command, exit code and result; browser checks include steps and observed state. Tests alone do not replace a smoke run of the changed path.
- Distinguish observed facts, assumptions and risks. Never weaken tests to match a defect, fabricate delegation/results, or claim existing features cannot regress.
- Status output: `Gate | Evidence/freshness | Blocker | Next command`. Report unavailable dependencies and unrun scenarios honestly.
- Never delete unrelated work, run destructive commands, merge, release, deploy or archive without explicit human authorization.
