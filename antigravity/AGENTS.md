# Engineering workflow activation

This is an opt-in workflow port. Do not activate it for ordinary questions, unrelated coding, or incidental mentions. Activate only when the user explicitly invokes one of the `/work-*`, `/review-*`, or `/security-audit` skills, or explicitly asks to use this workflow.

## Non-negotiable constraints

- The primary session owns user interaction, scope, approvals, orchestration, and final verification. Never delegate those responsibilities.
- Asking a question or invoking a skill is not approval. For each approval gate, state the decision and options, then STOP. Continue only after the user explicitly replies with the approving choice in the current conversation. Never infer approval from files, prior sessions, task checkboxes, or agent output.
- No application implementation before explicit Gate 2 approval in the current conversation.
- Quality-only reviews and QA are read-only for application source, tests, and specifications. Reports may be written only to their designated output directory.
- Reviewers must not see other reviewers' conclusions before completing their own work. Use fresh subagent sessions where available; if independence cannot be established, disclose it and mark the gate BLOCKED.
- Fingerprint the exact reviewed artifacts/diff. Any change after review invalidates the evidence and requires rerun.
- Preserve user changes. Stop on ambiguous scope, missing evidence, stale fingerprints, failed gates, or unavailable required tools.
- Never claim tests, browser actions, MCP calls, delegation, sandboxing, or verification that did not actually occur.
- Never merge, deploy, release, or publish without a separate explicit request.
- Keep reports concise, source-grounded, and actionable. Distinguish PASS, FAIL, and BLOCKED.

## Context and token discipline

- Load only the invoked skill and the minimum referenced files. Do not scan every skill or agent.
- Prefer targeted file reads, search, and diffs over recursive dumps.
- Keep handoffs compact: scope, paths, decisions, fingerprint, blockers, next action.
- At major milestones, preserve durable state in the repository's workflow artifacts before context compaction.
- Do not assume Antigravity compaction has OMP's configurable 60,000-token threshold.
