---
description: Verify implementation independently.
---
## Rule loading

Load `RULES.md`, `rules/core.md`, `rules/execution.md`, `rules/verification.md`, and `rules/gates.md`.

## Load and gate

- Always read installed shared `RULES.md` and `rules/core.md` from `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}`, then project `.omp/RULES.md` if present as additive policy. Resolve stage-rule paths under that shared base per its entrypoint. Stop if any required shared or applicable project policy is unreadable. Apply its dependencies, artifact ownership, stricter gates and freshness protocol.
- Change slug: $1. Enumerate all gate-bound artifacts and recompute every upstream SHA-256 manifest. Read the complete approved requirements/spec bundle, test plan and tasks; read the approval/review records and implementation evidence needed to establish freshness and authorization. Retrieve supporting documents on demand rather than loading every artifact body by default.
- Require current interview/spec/test-plan/tasks human approvals and independent review PASS records, all implementation tasks complete in `verification.md`, approved scope preserved and runnable checks available. Missing or stale evidence blocks verification.
- Keep approved `tasks.md` frozen. Record source identity as HEAD plus a digest manifest of changed tracked and relevant untracked files, explicitly including deletions; outside Git use a full relevant-source manifest. HEAD alone is insufficient.

## Independent verification

- Dispatch qa-engineer as an independent agent run with every approved acceptance criterion and TC, implementation identity, complete relevant diff/source context, affected regression surface and known risks. Give paths and manifest identities instead of duplicating full documents in the prompt; the QA agent must read authoritative criteria and retrieve any missing context. It must not verify its own authored implementation; if dispatch is unavailable, record BLOCKED and do not adopt the role.
- If QA dispatch is unavailable, record BLOCKED. Never adopt the QA or reviewer role yourself as a verification fallback or claim a dispatch happened.
- Have QA run the real repository-supported tests/checks and a smoke run of the changed path, using installed help for tools rather than guessed APIs. Record each raw command, exit code, observed result and rerunnable logs/evidence; RTK compression is not proof.
- Run agent shell commands through `rtk` per shared rules. Record actual Playwright, OpenSpec, security and RTK invocations in Evidence; preserve unfiltered failure output.
- Browser changes require actual Playwright execution of changed flows, error states, keyboard access and relevant viewport sizes. Record steps, observed states and browser evidence. Unavailable Playwright blocks browser verification; non-browser work records N/A with a reason.
- Cover every approved `TC-` and `REQ-`, plus affected existing-feature regressions. Record PASS/FAIL/BLOCKED/NOT_RUN per scenario; unrun/manual gaps and unavailable dependencies cannot become PASS.
- Check `interview.md` classification and the changed paths to decide whether security specialist review is required. Dispatch security-engineer only for security-sensitive changes or a credible risk found during QA/review, independent of the implementer and QA/reviewer. Otherwise, the reviewer must record why specialist review is N/A. When required, assess abuse paths and mitigations against the current source manifest and supply the result to the reviewer.
- After QA evidence exists (and security evidence when applicable), dispatch one independent reviewer with paths/manifests for the authoritative planning bundle, implementation diff/source, QA evidence, applicable security verdict, regression/compatibility risks and OpenSpec validation. The reviewer independently reads authoritative artifacts and actual evidence; a summary is navigation, not a substitute. Append manifest-bound findings and PASS/CHANGES_REQUESTED/BLOCKED to `review.md`. Do not run duplicate reviewers against the same unchanged manifest.
- Run installed OpenSpec validation and record the actual result. Recompute artifact/source manifests after the runs; any changed source/test/config invalidates prior verification and requires affected checks and independent review again.

## Handoff

- Write `verification.md` with QA and reviewer run identities, planning/source manifests, task completion evidence, scenario results, actual test/smoke/browser commands, validation results, applicable security review reference or N/A rationale, findings and remaining risks.
- Overall PASS requires every required scenario PASS, independent QA/reviewer PASS, validation PASS and no unresolved defects for current inputs. A security-engineer PASS is additionally required only when the change is security-sensitive or a credible security issue was identified. Otherwise state FAIL/BLOCKED/NOT_RUN with the exact missing or failing evidence.
- On PASS, present the shared checkpoint labelled `archive authorization`: evidence summary, manifests, remaining risks and the options `approve`, `approve stop`, `revisit: <task>`, `pause`. `approve` authorizes archive only; record it with the shared protocol and continue to `/work-archive $1` in the same turn, which proceeds without re-asking when the recorded authorization matches current inputs. `revisit` returns to the named task within approved scope; `pause` points to `/work-resume $1`.
- On FAIL/BLOCKED/NOT_RUN, present the failing evidence and the options `revisit: <task>`, `reject: <reason>`, `pause`. Never offer approval or archive for incomplete verification.
- Never archive, merge or release automatically; merge/release needs separate authorization.
