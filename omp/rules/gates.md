# Gate, ownership and approval rules

Load when creating, reviewing, approving, transitioning, verifying, or archiving a workflow stage.

## Artifacts and ownership

| Artifact | Owner | Minimum content |
| --- | --- | --- |
| `interview.md` | primary planning author using interviewer role | Source-backed decisions, selected options/rationale, users/journeys, current/desired behavior, REQ IDs, acceptance, non-goals, risks and resolved/blocking questions. |
| `prd.md` | product-manager | Human-readable product/mixed route: executive summary, user problem, desired experience, business rules, stable REQ IDs, measurable acceptance and success measures. |
| `design.md` | tech-lead | Human-readable technical design: current/proposed behavior, architecture rationale, alternatives, REQ IDs, impact, contracts, failure/security risks, rollout/rollback. |
| OpenSpec artifacts | tech-lead; product-manager consulted only for unresolved product interpretation | Installed schema's proposal and delta specs reflecting approved intent; design when required. Link REQ IDs; do not maintain competing requirements. |
| `test-plan.md` | qa-engineer | TC-to-REQ coverage, Given/When/Then, priority, layer, fixtures, expected results, affected existing-feature regression, manual gaps. |
| `task-breakdown.md` | tech-lead | Human-readable plan: milestones, approach, dependencies, risks and sequence of work. |
| `tasks.md` | tech-lead | Agent-ready OpenSpec implementation tasks linked to REQ/TC IDs, affected files, dependencies, rollout/rollback; created after QA planning. |
| `review.md` | reviewer + security-engineer | Append independent gate/security records: target, input path/digest manifest, PASS/CHANGES_REQUESTED/BLOCKED, file/line findings, risks, tool-use evidence or N/A reasons. Security records include red-team attack paths and blue-team mitigations. |
| `approvals.md` | orchestrator | Append-only human decisions binding exact artifact/input digests; never write approval on a human's behalf. |
| `verification.md` | qa-engineer + reviewer | Per TC/REQ result and real command/browser evidence, dependency invocations/results, implementation identity, regressions, review findings, remaining risks. |

- Product route requires PRD; engineering route requires design; mixed requires both. Record applicable N/A before review. Product work still needs design for material technical decisions or schema requirements. Approve the whole bundle, not a document title.
- Questions affecting scope, expected behavior, compatibility, security or data integrity block approval. Explicitly accepted nonblocking assumptions remain visible.
- Authors may use their role instructions directly if dispatch is unavailable and disclose it. Required independent gate review and final QA verification must be separate from the author/implementer; no self-review fallback. Use a separate security-engineer run only for security-sensitive changes or when a reviewer identifies a credible security risk. For routine low-risk changes, the independent reviewer checks security relevance and records why specialist review is N/A. If a required independent reviewer or QA run is unavailable, mark BLOCKED.

## Approval and freshness protocol

These are agent-enforced gates, not a runtime access-control mechanism. There is no `scripts/workflow_gate.py`; do not call it or claim automated enforcement.

1. Build a sorted, complete path/SHA-256 manifest with real hashing tools. `human-planning` binds `interview.md`, applicable `prd.md`/`design.md`, and `task-breakdown.md`. `execution` binds that entire bundle plus proposal, every delta spec, `test-plan.md`, `tasks.md`, and relevant installed OpenSpec configuration/schema inputs. Exclude mutable ledgers and project authoring guides; retain guide identities as supporting source context, not self-invalidating approval dependencies.
2. An independent reviewer records PASS for the same bundle manifest. Show artifact paths, findings, scope/risk and manifest before using built-in `ask` for approve/approve stop/revisit/pause. If unavailable, disclose it and await a numbered explicit response. A tool invocation, silence, generic “continue” or another target's approval is not consent.
3. Record only a decision made at this presented checkpoint and bound to the manifest just shown. A free-text directive such as “implement this”, “proceed on your own”, “go ahead” or “you have my approval” never binds an approval, even when it explicitly asks for implementation; state the missing obligation and the single command that obtains it. Never write an approval from prose, from a previous decision for different inputs, or on the operator's behalf. Schema overrides such as `skip_specs` never substitute for a bundle or its approval.
4. Recompute/re-enumerate inputs after the real decision. If unchanged, append target, UTC timestamp, decision reference/quote, manifest and matching review reference to `approvals.md`. If changed, disclose the delta and ask again. Never rewrite history.
5. Before transition/resume, recompute upstream manifests, including added/missing inputs. Relevant changed bytes invalidate the affected bundle and its dependents; preserve historical records. Changes to project authoring guides alone do not regenerate approved content. A guide change that requires an artifact-content/schema change follows ordinary re-review/reapproval.
6. Freeze approved task wording and checkboxes; track execution in `verification.md`. Reconcile completion-only checkboxes only on explicit archive authorization after verification, record it and rerun validation. Task-scope changes require renewed execution review/approval.
7. Bind verification to HEAD plus current changed tracked/relevant untracked/deleted-file digests, or a full relevant-source manifest outside Git. HEAD alone does not identify dirty source. Changed source/test/config invalidates affected verification; rerun affected checks and independent delta review.
8. Reuse exact unchanged evidence. A commit containing identical verified bytes may be rebound only with proof that source/test/config inputs and relevant tool/runtime context are equivalent; record old/new identity and mapping. A new hash, HEAD or schema PASS alone is not behavioral proof. New reviewers still inspect the authoritative inputs needed for their judgment.

## Gates

Every transition rechecks all upstream evidence. Missing, stale, FAIL, BLOCKED or NOT_RUN evidence never means PASS. Review PASS is not human approval. OpenSpec readiness is not human approval either.

| Operation | Required evidence / boundary |
| --- | --- |
| Interview, product/technical planning | Current-state investigation and aligned material decisions; author one human bundle. No separate interview approval or derived specs yet. |
| `/work-review` + `/work-approve` `human-planning` | Independent complete human-bundle PASS, no blocking unknowns, explicit approval of its exact manifest. |
| `work-prepare`, `work-qa`, `work-plan` | Fresh human-planning approval before any derived artifact; contribute specs, scenarios and tasks to one execution bundle. No intermediate human approvals. |
| `execution` approval | Complete fresh human/execution inputs, independent execution-bundle PASS, security PASS when required, full REQ/TC/task coverage, successful installed-schema validation, explicit human approval. |
| `work-implement` | Fresh human-planning and execution approvals; implement approved scope via `software-engineer` subagent on `@execution_tier`; main agent reviews and validates implementation before verification. |
| `work-verify` | Tasks complete, approved scope preserved, current source/checks available; separate independent QA and reviewer examine actual behavior/evidence. |
| Review-ready | Every required scenario PASS, fresh independent QA/reviewer PASS, required security PASS and OpenSpec validation PASS, no blocking defect; readable docs/code/test/QA/risk handoff. No human acceptance inferred. |
| `work-archive` | Review-ready evidence plus separate explicit human archive authorization matching current manifests. PR, deployment, merge and release remain separately requested. |

- Keep one continuing author/reviewer where practical; do not dispatch a new role merely to rewrite equivalent material. Each pre-build bundle gets one independent review and one human checkpoint, not one per constituent file.
- Re-review repairs only in the changed artifact, prior findings and dependent inputs; reuse proven-unchanged PASS coverage with its identity. Continue the existing reviewer when available. If the same finding class survives two re-reviews, surface it rather than loop.
- Stop at pending approval. An explicit custom-role invocation authorizes only that role's work, not a lifecycle transition. `/work-status` remains inspection-only.
- Material intent/scope changes return to human planning; changed spec/QA/task content returns to execution review/approval. Repair code within approved behavior, then repeat affected verification. Never alter expectations to fit defects.
- Required security review is a separate security-engineer red-team/blue-team run for sensitive scope or credible findings, bound to current inputs and covered by QA threat scenarios. Otherwise the independent reviewer records a specific security-N/A rationale. Reassess at final verification.
- Final QA and reviewer must be independent of implementers and each other; missing required independent evidence blocks readiness. Same operator-authorized model in separate runs is allowed; no silent paid escalation.

## Legacy changes

Preserve old artifacts/decisions. Enumerate their actual inputs and map coverage to each new bundle. Reuse only matching unchanged evidence; independently review missing/changed coverage and present an explicit human decision on the proposed mapping/manifest before a new-bundle transition. An old interview/spec/QA/tasks target is not an alias for `human-planning` or `execution`. Status/resume explain the next unmet obligation; they never auto-implement. A change already authorized under the old gates must finish those recorded obligations unless this reviewed mapping is explicitly approved; this workflow cannot self-bypass its own redesign.

## Human checkpoints

Each of the two pre-build bundles has one checkpoint after independent PASS. Role-only draft work does not force a lifecycle checkpoint. Keep it scannable:

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
- `/work-review <slug> <target>` handles the independent review of `human-planning` or `execution`; `/work-approve <slug> <target>` accepts only `human-planning` or `execution`, verifies prerequisites and records the actual decision. Archive authorization and execution are handled directly by `/work-archive <slug>`. No legacy-target aliases.

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

