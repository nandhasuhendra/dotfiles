---
description: Verify implementation independently.
---
## Load and gate

- Read project `.omp/RULES.md` if present; otherwise read `${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/RULES.md`. Stop if neither exists. Apply its dependencies, artifact ownership, gates and freshness protocol.
- Change slug: $1. Read the approved bundle, reviews, approvals and implementation evidence under `openspec/changes/$1/`, plus changed source/tests/config and repository check instructions.
- Re-enumerate inputs and recompute every upstream SHA-256 manifest. Require current interview/spec/test-plan/tasks human approvals and independent review PASS records, all implementation tasks complete in `verification.md`, approved scope preserved and runnable checks available. Missing or stale evidence blocks verification.
- Keep approved `tasks.md` frozen. Record source identity as HEAD plus a digest manifest of changed tracked and relevant untracked files, explicitly including deletions; outside Git use a full relevant-source manifest. HEAD alone is insufficient.

## Independent verification

- Dispatch qa-engineer and reviewer as independent agent runs with the approved bundle, implementation identity, complete diff/source context, TC/REQ matrix, task evidence and known risks. Neither may verify/review its own authored implementation; the reviewer must be separate from the QA run.
- If either independent dispatch is unavailable, record BLOCKED. Never adopt either role yourself as a verification fallback or claim a dispatch happened.
- Have QA run the real repository-supported tests/checks and a smoke run of the changed path, using installed help for tools rather than guessed APIs. Record each raw command, exit code, observed result and rerunnable logs/evidence; RTK compression is not proof.
- Browser changes require actual Playwright execution of changed flows, error states, keyboard access and relevant viewport sizes. Record steps, observed states and browser evidence. Unavailable Playwright blocks browser verification; non-browser work records N/A with a reason.
- Cover every approved `TC-` and `REQ-`, plus affected existing-feature regressions. Record PASS/FAIL/BLOCKED/NOT_RUN per scenario; unrun/manual gaps and unavailable dependencies cannot become PASS.
- Dispatch a separate security-engineer, independent of the implementer and QA/reviewer runs, with the planning/source manifests and evidence. Require red-team abuse-path review and blue-team mitigation verification, including legitimate-path regression evidence. It records a current-source verdict in `review.md`; missing dispatch/evidence means BLOCKED, and unresolved findings prevent PASS. Supply that result to the reviewer.
- Have the separate reviewer inspect implementation, QA evidence, regression/security/compatibility risks and OpenSpec validation results against the exact planning and source manifests. Append its identity, manifest-bound findings and PASS/CHANGES_REQUESTED/BLOCKED to `review.md`.
- Run installed OpenSpec validation and record the actual result. Recompute artifact/source manifests after the runs; any changed source/test/config invalidates prior verification and requires affected checks and independent review again.

## Handoff

- Write `verification.md` with QA, security-engineer and reviewer run identities, planning/source manifests, task completion evidence, scenario results, actual test/smoke/browser commands, validation results, security review reference, findings and remaining risks.
- Overall PASS requires every required scenario PASS, independent QA/security-engineer/reviewer PASS, validation PASS and no unresolved defects for current inputs. Otherwise state FAIL/BLOCKED/NOT_RUN with the exact missing or failing evidence.
- Record next gate: repair within approved scope and repeat verification, or `/work-archive $1` to request explicit human archive authorization. Never archive, merge or release automatically.
