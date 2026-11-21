---
description: Multi-phase security audit of a codebase with isolated hunters, adversarial verification and schema-validated findings. Args: [target] [quick|standard|deep] [output-dir]
---

# /security-audit [target] [quick|standard|deep] [output-dir]

Run the bundled `security-audit` skill end to end. You are the **parent**: you own every shared file, the budget, the ledger and the final verdicts. Workers are fresh, context-isolated agents; their independence is the product, so never hunt, verify or report in their place.

## Arguments

Parse `$1`, `$2`, `$3` left to right; later tokens win over inference.

- **target** (`$1`) — absolute repository root under review. Default: the active workspace root. Ask one focused question with `ask` only when the target is ambiguous or is not a repository.
- **profile** (`$2`) — `quick`, `standard` or `deep`. Default `standard`.
- **output-dir** (`$3`) — writable directory outside the target. Default: `~/security-audit-skill/<repo-name>/run-<N>` with the next unused `N`. A directory inside the target is allowed only when the user names it and you verify version control ignores the whole directory; otherwise stop and ask for an external path.
- A budget may be stated as a maximum agent-invocation count; otherwise leave it unset.

## Mode selection

This command is full-audit mode. If the user's request is a security question or a focused vulnerability investigation rather than an audit, say so and use the skill's guidance mode instead: read only the relevant skill sections, launch no audit phases, write no artifacts.

## Load the skill

Skill directory: `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/skills/security-audit`.

Read `SKILL.md` first. Then read each phase file immediately before running that phase; never pre-read the whole skill:

| Phase | Read |
| --- | --- |
| Setup and all phases | `SKILL.md` |
| 1 Reconnaissance | `RECONNAISSANCE.md` |
| 2 Hunting | `HUNTING.md`, `ATTACK-CLASSES.md`, each selected companion |
| 3–6 Validation and reporting | `VALIDATION-AND-REPORTING.md`, `report-schema.json` |

Do not paraphrase the copy-ready prompt blocks, JSON contracts or promotion procedure from those files into worker prompts. Copy them verbatim.

## Non-negotiable execution boundary

- Source inspection is read-only. Target-controlled builds, tests, processes, browsers, emulators, fuzzers and fixtures run only inside the OS-enforced sandbox the skill requires (no external network, empty allowlisted environment, read-only target and toolchain, scratch-only writes, explicit low CPU/memory/process/file-size/disk/wall-clock limits).
- Never contact deployed endpoints, provider APIs, registries, identity systems, brokers, shared services or other users. Dummy principals, fixtures and secrets only.
- If any sandbox or promotion control cannot be enforced, do not execute target code. Keep the lead as `needs_validation` with the exact blocker and a safe validation plan.
- Reject live probes, availability stress, publishing, real credentials, persistence and any step past the minimum observed boundary result.

## Write isolation

You are the only writer of `<output-dir>/run-metadata.json`, `architecture.md`, `coverage-ledger.json`, `findings.json`, `REPORT.md`, `FINDINGS-DETAIL.md` and `NEEDS-VALIDATION.md`.

Give every worker its own `<output-dir>/agents/<agent-id>/{scratch,artifacts}/`. Worker IDs match `^[a-z0-9][a-z0-9_-]{0,63}$`, are lowercase and are never Windows device names. Workers write only to `scratch/` and never to shared files, target source, another worker's directory or retained artifacts. Promote allowlisted scratch files only through the descriptor-safe parent procedure in the skill; never glob, recurse or follow links.

## Workflow

### 1. Setup

1. Resolve and state skill directory, target, repo name, output directory, source ref (commit plus dirty-worktree status) and profile.
2. Apply the strict pre-reconnaissance budget gate. If the budget cannot fund the baseline reconnaissance, final critics and at least one verifier, launch nothing and record `run_status: "incomplete"` with the skill's exact reason.
3. Create the output tree and write `run-metadata.json` with at least `run_id`, `repo`, `target`, `source_ref`, `profile`, `scope_paths`, `budget`, `execution_policy: "sandboxed-source-and-local-only"`, selected companion files, prior-run paths, shared-file owners and `run_status: "in_progress"`.

### 2. Phase 1 — Reconnaissance

Launch the four reconnaissance prompts from `RECONNAISSANCE.md` (1a product/stack, 1b principals/controls, 1c entry surfaces/sinks, 1d local execution/deployment visibility) in parallel through the `security-audit-recon` agent. Add focused recon only if a materially distinct deployment mode or subsystem is unmapped and the budget allows; otherwise seed it as `deferred`.

Read every compatible prior `coverage-ledger.json` and `findings.json` first and apply the skill's prior-run carry/revalidate rules exactly.

Synthesize `architecture.md` (about 1,000 words), then seed `coverage-ledger.json` per `RECONNAISSANCE.md` and run:

```sh
node <skill-dir>/validate-coverage-ledger.cjs <output-dir>/coverage-ledger.json
```

An invalid ledger blocks any assignment.

### 3. Phase 2 — Coverage-led hunting

Assign `planned` units in the skill's priority order, set them `in_progress` and dispatch `security-audit-hunter` with the full required hunter prompt (architecture verbatim, assigned units, verbatim attack-class blocks, exclusions with reasons, hunting method, promotion procedure, validation rules, prior exclusions, scratch contract and the structured JSON result contract). One hunter may own closely related units; no unit may be silently unassigned.

Consolidate each result into exactly its assigned unit, archive `hardening` notes in ledger bookkeeping, deduplicate candidates by fingerprint then root cause, and validate the ledger after every update.

After each wave, spend the reserved invocation on a fresh `security-audit-recon` coverage critic returning the skill's critic JSON. Accept only in-scope, source-grounded gaps; archive reopened attempts; iterate per profile. `quick` runs exactly one hunter wave and one final critic, then records accepted discoveries as `deferred` with `quick_profile_final_critic`.

### 4. Phase 3 — Candidate validation

Give every unique candidate and carried prior confirmation to a fresh `security-audit-verifier` that did not hunt it, with the candidate, linked checks/artifacts, architecture facts, verbatim schema branches, promotion procedure and prior same-fingerprint records. It must re-read cited source and independently reproduce decisive checks. Expect exactly `{"decision": "confirmed|needs_validation|rejected", "record": {...}}`. Discard malformed results; re-run with a fresh verifier when budget permits.

### 5. Phase 4 — Structured output

Write all decided records to `<output-dir>/findings.json`, sorted by fingerprint, then run both validators and fix every error:

```sh
node <skill-dir>/validate-findings.cjs <output-dir>/findings.json
node <skill-dir>/validate-coverage-ledger.cjs <output-dir>/coverage-ledger.json
```

### 6. Phase 5 — Independent record verification

Launch one fresh `security-audit-verifier` per final `confirmed` and `needs_validation` record. It returns `{"decision":"verified","fingerprint":"..."}` or `{"decision":"replace","reason":"...","record":{...}}`. Apply only non-material corrections directly. A promotion to a stronger verdict or a material change to root cause, trace, execution, impact or severity needs another independent verifier; if that is unavailable, remove the record, keep the unit as an unresolved candidate and mark the run incomplete. Re-run both validators after every applied replacement.

`quick` merges Phases 3 and 5 into the single fresh verifier; never skip independent review of a `confirmed` record.

### 7. Phase 6 — Reporting

After every retained record passes Phase 5, derive `REPORT.md`, `FINDINGS-DETAIL.md` and `NEEDS-VALIDATION.md` from the verified records and ledger. Reports never change a verdict, severity, blocker or demonstrated impact, never assign severity to `needs_validation`, and never describe rejected records or unvalidated candidates as findings. State partial coverage, deferred and out-of-scope units, critic results and budget spend plainly. Set `run_status: "complete"` only when all phases and both validators pass; otherwise record `incomplete` with its exact reason.

## Delegation map

| Work | Agent | Result |
| --- | --- | --- |
| 1a–1d reconnaissance, coverage critic | `security-audit-recon` | Source facts with repository-relative `file:line`, or the critic JSON contract |
| Phase 2 units | `security-audit-hunter` | Exactly one JSON hunter result per assignment |
| Phases 3 and 5 | `security-audit-verifier` | Exactly one decision JSON per candidate or record |

Send each worker only what its prompt contract allows: never another verifier's conclusion, never pre-existing verdicts as anchors. Do not delegate the same fingerprint to two workers in one phase.

## Terminal states

End only in one of two states: (a) all Phase 6 artifacts written and both validators pass, or (b) `run_status: "incomplete"` with the exact reason and the gap disclosed in the report. Never stop mid-phase, never claim a check, tool run or agent result that did not occur, and never let agent count or a silent cap stand in for coverage evidence.

## Report back

Return the run directory, profile, source ref, `run_status`, confirmed/needs-validation/rejected counts, validator results, coverage gaps and the single most important owner action. Keep the handoff compact; the artifacts carry the detail.
